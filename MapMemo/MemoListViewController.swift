//
//  MemoListViewController.swift
//  MapMemo
//
//  Created by Enxhi Qemalli on 23.4.24.
//

import UIKit
import Combine

class MemoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView: UITableView!
    var memos: [Note] = []
    var filteredMemos: [Note] = []
    
    private var cancellables: [AnyCancellable] = []
    var searchController: UISearchController = UISearchController()
    
    var isSearchActive: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        reloadMemos() // Load or populate the memos array with data
        let customButton = UIButton(type: .custom)
        customButton.setTitle("Activity", for: .normal)
        customButton.setTitleColor(.darkText, for: .normal)
        let buttonSize = CGSize(width: 40, height: 40) // Adjust the size as needed
        customButton.frame = CGRect(origin: .zero, size: buttonSize)
        customButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -250, bottom: 0, right: 0)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        navigationItem.titleView = customButton
        
        searchController = UISearchController(searchResultsController: nil)
           searchController.searchResultsUpdater = self
           searchController.obscuresBackgroundDuringPresentation = false
           searchController.searchBar.placeholder = "Search Notes"
           navigationItem.searchController = searchController
           definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reloadMemos()
    }
    
    private func setupNavigationBar() {
        let saveImage = UIImage(systemName: "square.and.arrow.down")
        let saveButton = UIBarButtonItem(image: saveImage, style: .plain, target: self, action: #selector(saveButtonTapped))
            navigationItem.rightBarButtonItem = saveButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    @objc private func saveButtonTapped() {
        // Implement memo saving logic here
        let alertController = UIAlertController(title: "Confirm Download", message: "Are you sure you want to download all notes?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Download", style: .destructive, handler: { [weak self] _ in
            self?.saveMemosToFile()
        }))
        present(alertController, animated: true, completion: nil)
        
    }
    
    private func saveMemosToFile() {
        let csvFileName = "Memos.csv"
        guard let documentDirectoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Unable to get document directory path.")
            return
        }
        
        let csvFilePath = documentDirectoryPath.appendingPathComponent(csvFileName)
        var csvText = "Title,Date,Description,Latitude,Longitude\n" // CSV header
        
        // Add memo data to the CSV text
        for memo in memos {
            let escapedTitle = escapeCSVField(memo.title)
            let escapedDescription = escapeCSVField(memo.content)
            let memoLine = "\(escapedTitle),\(memo.date),\(escapedDescription),\(memo.latitude),\(memo.longitude)\n"
            csvText.append(memoLine)
        }
        
        do {
            try csvText.write(to: csvFilePath, atomically: true, encoding: .utf8)
            print("CSV file saved: \(csvFilePath)")
            // Optionally, you can provide a way for the user to access the saved file, such as displaying a share sheet.
        } catch {
            print("Error saving CSV file: \(error.localizedDescription)")
        }
    }
    
    
    private func escapeCSVField(_ field: String) -> String {
        // Escape special characters in CSV field
        var escapedField = field.replacingOccurrences(of: "\"", with: "\"\"") // Escape double quotes
        escapedField = "\"\(escapedField)\"" // Enclose field in double quotes
        return escapedField
    }
    
    func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MemoTableViewCell.self, forCellReuseIdentifier: MemoTableViewCell.reuseIdentifier)
        tableView.separatorStyle = .none
        view.addSubview(tableView)
    }
    
    func reloadMemos() {
        
        memos = NoteData.shared.loadNotes()
        tableView.reloadData()
    }
    
    private func deleteButtonTapped(id: String) {
        // Show confirmation popup
        let alertController = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this note?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.didTapDeleteButton(id: id)
        }))
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchActive ? filteredMemos.count : memos.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memo = isSearchActive ? filteredMemos[indexPath.row] : memos[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoTableViewCell.reuseIdentifier, for: indexPath) as? MemoTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: memo)
                  

              cell.deleteSubject
                  .prefix(1)
                  .sink { [weak self] in
                      self?.deleteButtonTapped(id: memo.id)
                  }
                  .store(in: &cell.cancellables)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedMemo = memos[indexPath.row]
            let newNoteVC = NewNoteViewController(memo: selectedMemo, mode: .edit)
        newNoteVC.dismissPublisher
            .sink { [weak self] in
                self?.reloadMemos()
            }
            .store(in: &cancellables)
        let navController = UINavigationController(rootViewController: newNoteVC)
        present(navController, animated: true, completion: nil)
        }
    
    func didTapDeleteButton(id: String) {
        //var localMemos = NoteData.shared.loadNotes()
        //let memo = localMemos[indexPath.row]
        NoteData.shared.deleteNote(noteId: id)
        //memos.remove(at: indexPath.row)
       // self.memos = localMemos
        reloadMemos()
    }
}

extension MemoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        if searchText.isEmpty {
            filteredMemos = memos
        } else {
            filteredMemos = memos.filter { memo in
                return memo.title.lowercased().contains(searchText.lowercased()) ||
                       memo.content.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }
}

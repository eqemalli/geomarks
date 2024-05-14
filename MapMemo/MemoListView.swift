//
//  MemoListView.swift
//  MapMemo
//
//  Created by Enxhi Qemalli on 23.4.24.
//

import UIKit

class MemoListView: UIView {
    private let tableView = UITableView()
    private var notes: [Note] = []

    // Declaration of the ViewModel property
    var viewModel: MemoListViewModel? {
        didSet {
            setupBindings()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        addSubview(tableView)
        tableView.frame = bounds
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    private func setupBindings() {
        guard let viewModel = viewModel else { return }
        notes = viewModel.loadNotes()
        tableView.reloadData()
    }
}

extension MemoListView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath)
        let note = notes[indexPath.row]
        //cell.titleLabel?.text = note.title
        //cell.contentTextView.text = note.content
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
            //delete from user defaults
        }
    }
}

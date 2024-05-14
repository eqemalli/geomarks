//
//  AllMemosViewController.swift
//  MapMemo
//
//  Created by Enxhi Qemalli on 23.4.24.
//

import UIKit
import MapKit
import Combine

class AllMemosViewController: UIViewController, MKMapViewDelegate {
    var contentView = UIView()
    var mapView: MKMapView!
    private var cancellables = Set<AnyCancellable>()
    private var mapTypeSegmentedControl: UISegmentedControl!
    private let mapTypeKey = "MapType"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let customButton = UIButton(type: .custom)
        customButton.setTitle("GeoNotes", for: .normal)
        customButton.setTitleColor(.darkText, for: .normal)
        let buttonSize = CGSize(width: 40, height: 40) // Adjust the size as needed
        customButton.frame = CGRect(origin: .zero, size: buttonSize)
        customButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -250, bottom: 0, right: 0)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        navigationItem.titleView = customButton
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        contentView.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
        addAnnotations()
        setupMapTypeSegmentedControl()
        loadSavedMapType()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshAnnotations()
    }
    
    func setupMapTypeSegmentedControl() {
        mapTypeSegmentedControl = UISegmentedControl(items: ["Standard", "Satellite", "Hybrid"])
        mapTypeSegmentedControl.selectedSegmentIndex = 0 // Default to Standard map type
        mapTypeSegmentedControl.addTarget(self, action: #selector(mapTypeChanged(_:)), for: .valueChanged)
        mapTypeSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapTypeSegmentedControl)
        
        NSLayoutConstraint.activate([
            mapTypeSegmentedControl.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -10),
            mapTypeSegmentedControl.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    func loadSavedMapType() {
        if let savedMapType = UserDefaults.standard.value(forKey: mapTypeKey) as? Int {
            mapTypeSegmentedControl.selectedSegmentIndex = savedMapType
            mapTypeChanged(mapTypeSegmentedControl)
        }
    }
    
    @objc func mapTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        case 2:
            mapView.mapType = .hybrid
        default:
            break
        }
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: mapTypeKey)
    }
    
    @objc func addButtonTapped() {
        let newNoteVC = NewNoteViewController(mode: .add)
        newNoteVC.dismissPublisher
            .sink { [weak self] in
                self?.refreshAnnotations()
            }
            .store(in: &cancellables)
        let navController = UINavigationController(rootViewController: newNoteVC)
        present(navController, animated: true, completion: nil)
    }
    
    func addAnnotations(){
        let notes = NoteData.shared.loadNotes()
        for note in notes{
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: note.latitude, longitude: note.longitude)
            annotation.title = note.title
            annotation.subtitle = note.content
            mapView.addAnnotation(annotation)
        }
    }
    
    func refreshAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
        addAnnotations()
    }
}

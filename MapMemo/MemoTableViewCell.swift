//
//  MemoTableViewCell.swift
//  MapMemo
//
//  Created by Enxhi Qemalli on 4.5.24.
//

import UIKit
import MapKit
import Combine

class MemoTableViewCell: UITableViewCell {
    static let reuseIdentifier = "MemoTableViewCell"
    
    var containerView: UIView!
    var mapView: MKMapView!
    var titleLabel: UILabel!
    var dateLabel: UILabel!
    var descriptionLabel: UILabel!
    var deleteButton: UIButton!
    var isConfigured = false
    var deleteSubject = PassthroughSubject<Void, Never>()
    var cancellables: [AnyCancellable] = []
    private let mapTypeKey = "MapType"

//    var deletePublisher: AnyPublisher<Void, Never> {
//        deleteSubject.eraseToAnyPublisher()
//    }
//    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupContainerView()
        setupMapView()
        setupTitleLabel()
        setupDateLabel()
        setupDeleteButton()
        setupDescriptionLabel()
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContainerView()
        setupMapView()
        setupTitleLabel()
        setupDateLabel()
        setupDeleteButton()
        setupDescriptionLabel()
        self.selectionStyle = .none
    }
    
    private func setupContainerView() {
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 8.0
        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        contentView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupMapView() {
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 8.0
        containerView.addSubview(mapView)
        loadSavedMapType()

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            mapView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            mapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            mapView.heightAnchor.constraint(equalToConstant: 200) // Adjust height as needed
        ])
    }
    
    private func setupTitleLabel() {
        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupDateLabel() {
        dateLabel = UILabel()
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.systemFont(ofSize: 12)
        containerView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
        ])
    }
    
    private func setupDescriptionLabel() {
        descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 2
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        containerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: 8),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    private func setupDeleteButton() {
        deleteButton = UIButton(type: .system)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        containerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            deleteButton.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -8),
            deleteButton.heightAnchor.constraint(equalToConstant: 25),
            deleteButton.widthAnchor.constraint(equalToConstant: 25)
        ])
        
    }
    
    @objc private func deleteButtonTapped() {
        deleteSubject.send(())
    }
    
    func configure(with memo: Note) {
        titleLabel.text = memo.title
        dateLabel.text = "Last edited: " + DateFormatter.localizedString(from: memo.date, dateStyle: .medium, timeStyle: .short)
        descriptionLabel.text = memo.content
        
        mapView.removeAnnotations(mapView.annotations)

        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: memo.latitude, longitude: memo.longitude)
        mapView.addAnnotation(annotation)
        
        // Zoom to the annotation
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        loadSavedMapType()
    }
    
    func loadSavedMapType() {
            if let savedMapType = UserDefaults.standard.value(forKey: mapTypeKey) as? Int {
                switch savedMapType {
                case 0:
                    mapView.mapType = .standard
                case 1:
                    mapView.mapType = .satellite
                case 2:
                    mapView.mapType = .hybrid
                default:
                    break
                }
            }
        }
}

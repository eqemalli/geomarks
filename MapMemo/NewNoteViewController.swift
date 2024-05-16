import UIKit
import MapKit
import Combine

class NewNoteViewController: UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView = UIScrollView()
    var contentView = UIView()
    var mapView: MKMapView!
    var titleTextField: UITextField!
    var contentTextField: UITextView!
    var pinAnnotation: MKPointAnnotation?
    let dismissPublisher = PassthroughSubject<Void, Never>()
    private let mapTypeKey = "MapType"

    var memo: Note?
    var mode: EditMode = .add

    enum EditMode {
        case add
        case edit
    }

    init(memo: Note? = nil, mode: EditMode) {
        self.memo = memo
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupScrollView()
        setupContentView()
        setupMapView()
        setupTitleTextField()
        setupContentTextField()
        setupNavigationBar()
        view.backgroundColor = .systemGroupedBackground
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        loadSavedMapType()
        if mode == .edit, let memo = memo {
                    titleTextField.text = memo.title
                    contentTextField.text = memo.content
                    setMapViewLocation(latitude: memo.latitude, longitude: memo.longitude)
        }else{
            setMapViewRegion()
        }
    }
    
    func setMapViewLocation(latitude: Double, longitude: Double) {
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
           let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
           mapView.setRegion(region, animated: true)
           
           // Create an annotation
           let annotation = MKPointAnnotation()
           annotation.coordinate = coordinates
           
           // Add the annotation to the map view
           mapView.addAnnotation(annotation)
            pinAnnotation = annotation
        
    }
    
    func setMapViewRegion(){
        let notes = NoteData.shared.loadNotes()
        if !notes.isEmpty, let note = notes.last{
            let coordinates = CLLocationCoordinate2D(latitude: note.latitude, longitude: note.longitude)
               let region = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
               mapView.setRegion(region, animated: true)
        }
    }
    
    func setupScrollView() {
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(scrollView)
            
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        //scrollView.isScrollEnabled = true
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height * 2)
        }

    func setupContentView(){
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    func setupMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mapView)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5)
        ])
        
    }
    
    func setupTitleTextField() {
        titleTextField = UITextField()
        titleTextField.placeholder = "Title"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleTextField)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    func setupContentTextField() {
        contentTextField = UITextView()
        contentTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentTextField)
        
        NSLayoutConstraint.activate([
            contentTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            contentTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        contentTextField.font = UIFont.systemFont(ofSize: 16)
    }
    
    func setupNavigationBar() {
        if mode == .edit{
            navigationItem.title = "Edit Note"
        }else{
            navigationItem.title = "New Note"
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveButtonTapped))
    }
    
    @objc func saveButtonTapped() {
        guard let title = titleTextField.text, let content = contentTextField.text, let annotation = pinAnnotation else {
            let alertController = UIAlertController(title: "Location Required", message: "Please select a location on the map to save the new note.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        if mode == .edit, var editedMemo = memo {
            NoteData.shared.editNote(noteId: editedMemo.id, title: title, content: content, latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, date: Date())
        }else{
            NoteData.shared.createNewNote(title: title, content: content, latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, date: Date())
        }

        dismissPublisher.send()
        self.navigationController?.dismiss(animated: true)
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            let locationInView = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            if pinAnnotation == nil { // Add only one pin initially
                // Add a pin annotation at the tapped location
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
                pinAnnotation = annotation
            } else { // Update pin location if already added
                pinAnnotation?.coordinate = coordinate
            }
        }
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

extension NewNoteViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        pinView.canShowCallout = true
        pinView.isDraggable = true
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
            if newState == .ending {
                if let annotation = view.annotation as? MKPointAnnotation {
                    pinAnnotation = annotation
                }
            }
        }
}

extension NewNoteViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // Adjust text field position
            let textFieldFrame = titleTextField.convert(titleTextField.bounds, to: scrollView)
            let textFieldMaxY = textFieldFrame.maxY
            let keyboardMinY = UIScreen.main.bounds.height - keyboardFrame.height
            let offsetY = max(0, textFieldMaxY - keyboardMinY)
            scrollView.contentOffset = CGPoint(x: 0, y: offsetY)
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}

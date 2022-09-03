//
//  ViewController.swift
//  MapsSample
//
//  Created by Hasan Uysal on 2.09.2022.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
    var locationManager = CLLocationManager()
    
    var choosedLatitude = Double()
    var choosedLongitude = Double()
    
    var receiveName = ""
    var receiveId: UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() // add cause of accessing in "info.plist" file
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gR: )))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if receiveName != "" {
            
            if let uuidString = receiveId?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        
                        for result in results as! [NSManagedObject] {
                            
                            if let name = result.value(forKey: "name") as? String{
                                annotationTitle = name
                                
                                if let note = result.value(forKey: "note") as? String{
                                    annotationSubtitle = note
                                    
                                    if let latitude = result.value(forKey: "latitude") as? Double{
                                        annotationLatitude = latitude
                                        
                                        if let longitude = result.value(forKey: "longitude") as? Double{
                                            annotationLongitude = longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle = annotationSubtitle
                                            
                                            let coordinate = CLLocationCoordinate2DMake(annotationLatitude, annotationLongitude)
                                            
                                            annotation.coordinate = coordinate
                                            
                                            mapView.addAnnotation(annotation)
                                            
                                            nameTextField.text = annotationTitle
                                            noteTextField.text = annotationSubtitle
                                            
                                            locationManager.stopUpdatingLocation()
                                            
                                            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 0.1, longitudinalMeters: 0.1)
                                            
                                            mapView.setRegion(region, animated: true)
                                            
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                } catch {
                    print("error")
                }
            }
        }
    }
    
    @objc func chooseLocation(gR: UILongPressGestureRecognizer){
        
        if gR.state == .began {
            
            let locationPress = gR.location(in: mapView)
            let coordinatePress = mapView.convert(locationPress, toCoordinateFrom: mapView)
            
            choosedLatitude = coordinatePress.latitude
            choosedLongitude = coordinatePress.longitude
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = coordinatePress
            annotation.title = nameTextField.text
            annotation.subtitle = noteTextField.text
            mapView.addAnnotation(annotation)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if receiveName == "" {
            
            let location = CLLocationCoordinate2DMake(locations[0].coordinate.latitude, locations[0].coordinate.longitude)
            
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 0.1, longitudinalMeters: 0.1)
            
            mapView.setRegion(region, animated: true)
            
        }
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        newLocation.setValue(nameTextField.text, forKey: "name")
        newLocation.setValue(noteTextField.text, forKey: "note")
        newLocation.setValue(choosedLatitude, forKey: "latitude")
        newLocation.setValue(choosedLongitude, forKey: "longitude")
        newLocation.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("data saved")
        } catch {
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newLocCreated"), object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .red

            let detailButton = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = detailButton
            
        } else {
            
            pinView?.annotation = annotation
            
        }
        
        return pinView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if receiveName != "" {
          
            let locationCL = CLLocation(latitude: annotationLatitude,longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(locationCL) { (placeMarkArr, hata) in
                if let placemarks = placeMarkArr {
                    if placemarks.count > 0 {
                        
                        let newPlaceMark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: newPlaceMark)
                        
                        item.name = self.annotationTitle
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        
                        item.openInMaps(launchOptions: launchOptions)
                        
                    }
                }
            }
            
        } 
    }
    
    
}


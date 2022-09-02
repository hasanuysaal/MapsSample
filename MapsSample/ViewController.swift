//
//  ViewController.swift
//  MapsSample
//
//  Created by Hasan Uysal on 2.09.2022.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var noteTextField: UITextField!
    
    var locationManager = CLLocationManager()
    
    var choosedLatitude = Double()
    var choosedLongitude = Double()
    
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
        
        
        let location = CLLocationCoordinate2DMake(locations[0].coordinate.latitude, locations[0].coordinate.longitude)

        let region = MKCoordinateRegion(center: location, latitudinalMeters: 0.05, longitudinalMeters: 0.05)
        
        mapView.setRegion(region, animated: true)
        
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
        
        
        
    }
    

}


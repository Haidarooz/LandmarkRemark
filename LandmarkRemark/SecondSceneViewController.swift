//
//  SecondSceneViewController.swift
//  LandmarkRemark
//
//  Created by Haidar Mohammed on 3/11/18.
//  Copyright © 2018 Haidar AlOgaily. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit
import FirebaseDatabase

class SecondSceneViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate {

    @IBOutlet var map: MKMapView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var addNoteView: UIView!
    @IBOutlet var addNoteText: UITextView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        map.delegate = self
        
        setupLocationManager()
        setUpUIelements()
        loadExistingAnnotations()
        observeNewLocationNotes()
       
    }
    
 
    @IBAction func cancelButtonClicked(_ sender: Any) {
        
        addNoteView.isHidden = true
        addNoteText.resignFirstResponder()
        
    }
    @IBAction func addNewNoteButtonClicked(_ sender: Any) {
        addNoteView.isHidden = false
        addNoteText.text = ""
        addNoteText.becomeFirstResponder()
        
    }
    @IBAction func confirmAddingNoteClicked(_ sender: Any) {
        
        guard let latitude = locationManager.location?.coordinate.latitude else { return }
        guard let longitude = locationManager.location?.coordinate.longitude else { return }
        guard let text = addNoteText.text else { return }

       
        let note = LocationNote(altitude: latitude, longitude: longitude, text: text)
        saveLocationNote(note: note)

            
        
        addNoteView.isHidden = true
        addNoteText.resignFirstResponder()
       
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //get most recent location
        let currentLocation = locations[0]
        
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let myLocation = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: myLocation, span: span)
       // map.setRegion(region, animated: true)
        map.showsUserLocation = true
        
        
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        
    try! Auth.auth().signOut()
    self.dismiss(animated: true)
    }
    
    fileprivate func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func setUpUIelements() {
    
    addButton.layer.cornerRadius = addButton.bounds.size.height/2
    addButton.layer.shadowOffset = CGSize(width: -1, height: 1)
    addButton.layer.shadowOpacity = 0.2
    addNoteView.layer.cornerRadius = 10
    addNoteView.layer.shadowOffset = CGSize(width: -1, height: 1)
    addNoteView.layer.shadowOpacity = 0.2
        
}
    
    func saveLocationNote (note: LocationNote){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
    
        let reference = Database.database().reference().child("users/\(uid)/notes").childByAutoId()
        
        let userData = [
            
            "longitude" : note.longitude,
            "latitude" : note.altitude,
            "text" : note.text
            
        ] as [String : Any]
        
        reference.setValue(userData)
    }
    
   
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //print("Annotation selected")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        //if annotation is of kind MKUserLocation, dont change it, return
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        //Creating Deqeueble annotation
        let identifier = "somePin"
        var annotationView: MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        //Creating annotation if its not Deqeueble
        if annotationView == nil {
            
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            annotationView?.canShowCallout = true
            
            let aTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            
            aTextView.text = annotation.subtitle!
            aTextView.font = UIFont.systemFont(ofSize: 13)
            aTextView.textColor = UIColor.darkGray
            aTextView.isEditable = false
            annotationView!.detailCalloutAccessoryView = aTextView;
            
            let width = NSLayoutConstraint(item: aTextView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
            aTextView.addConstraint(width)
            let height = NSLayoutConstraint(item: aTextView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 90)
            aTextView.addConstraint(height)
            
            
            
            
        } else {
            annotationView!.annotation = annotation
        }
        
     

        //configureAnnotationView(annotationView: annotationView)

        return annotationView
    }
    
    func addNoteToMap(lat: CLLocationDegrees, long: CLLocationDegrees,title: String,text: String) {
        
                  let location  = CLLocationCoordinate2D(latitude: lat, longitude: long)
                  let annotation = MKPointAnnotation()
                  annotation.coordinate = location
                  annotation.title = title
                  annotation.subtitle = text
                  map.addAnnotation(annotation)
        
    }
    
    func loadExistingAnnotations(){
        
        let reference = Database.database().reference()
        reference.child("users").observe(.childAdded) { snapshot in

            for userData in snapshot.children.allObjects as! [DataSnapshot] {
                
                let username = (snapshot.value as? NSDictionary)?["username"] as? String ?? ""

                if userData.key == "notes" {
                   
                    for notesData in userData.children.allObjects as! [DataSnapshot] {
                        
                        let locationNote = notesData.value as? [String : AnyObject]
                        let longitude = locationNote?["longitude"] as! CLLocationDegrees
                        let latitude = locationNote?["latitude"] as! CLLocationDegrees
                        let text = locationNote?["text"] as! String
                        
                        self.addNoteToMap(lat: latitude, long: longitude, title: username, text: text)
                        print("Added an existing annotation")
                    }
                    
                }
                
            }
            
        }
    }
    
    func observeNewLocationNotes(){
        
        let reference = Database.database().reference().child("users/")
        reference.observe(.childChanged, with: { (snapshot : DataSnapshot) in
            
            for userData in snapshot.children.allObjects as! [DataSnapshot] {
                
                let username = (snapshot.value as? NSDictionary)?["username"] as? String ?? ""
                
                if userData.key == "notes" {
                    
                    let lastAddedItem = userData.children.allObjects.last as! DataSnapshot
                    
                    print(lastAddedItem.value)
                    let locationNote = lastAddedItem.value as? [String : AnyObject]
                    let longitude = locationNote?["longitude"] as! CLLocationDegrees
                    let latitude = locationNote?["latitude"] as! CLLocationDegrees
                    let text = locationNote?["text"] as! String
                    
                    self.addNoteToMap(lat: latitude, long: longitude, title: username, text: text)
                    print("Added a new note!")
                
                }
            }

        } )
        

    }
    
}



extension CLLocationCoordinate2D {
    
    /// Compare two coordinates
    /// - parameter coordinate: another coordinate to compare
    /// - return: bool value
    func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
        
        if self.latitude != coordinate.latitude &&
            self.longitude != coordinate.longitude {
            return false
        }
        return true
    }
    
    /// check the coordinate is empty or default
    /// return Bool value
    var isDefaultCoordinate: Bool {
        
        if self.latitude == 0.0 && self.longitude == 0.0 {
            return true
        }
        return false
    }
}

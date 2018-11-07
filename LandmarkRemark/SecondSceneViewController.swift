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

class SecondSceneViewController: UIViewController,CLLocationManagerDelegate,MKMapViewDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UINavigationBarDelegate {
   
    @IBOutlet var logoutButton: UIBarButtonItem!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var map: MKMapView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var addNoteView: UIView!
    @IBOutlet var addNoteText: UITextView!
    let locationManager = CLLocationManager()
    var isSearching = false
    var notesArray = [NSDictionary?]()
    var filteredNotesArray = [NSDictionary?]()

    @IBOutlet var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        map.delegate = self
        table.delegate = self
        table.dataSource = self
        navigationBar.delegate = self
        
        setupLocationManager()
        setUpUIelements()
        setupSearchBar()
        
        table.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        let myLocation = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        let latDelta: CLLocationDegrees = 0.05
        let lonDelta: CLLocationDegrees = 0.05
        let span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: span)
        self.map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
        self.locationManager.stopUpdatingLocation()

        
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        
    try! Auth.auth().signOut()
    self.dismiss(animated: true)
        
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        
        notesArray.removeAll()
        filteredNotesArray.removeAll()
    }
    
    fileprivate func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    fileprivate func setUpUIelements() {
    
    addButton.layer.cornerRadius = addButton.bounds.size.height/2
    addButton.layer.shadowOffset = CGSize(width: -1, height: 1)
    addButton.layer.shadowOpacity = 0.2
    addNoteView.layer.cornerRadius = 10
    addNoteView.layer.shadowOffset = CGSize(width: -1, height: 1)
    addNoteView.layer.shadowOpacity = 0.2
        
}
    
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       
        if searchBar.text == nil {
            self.view.endEditing(true)
            table.reloadData()
        }
        else {
            isSearching = true
            
            filterSearchResults(searchText: searchText)
            
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        table.isHidden = false
        searchBar.showsCancelButton = true
        isSearching = true
        logoutButton.title = ""
    }
  
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.showsCancelButton = false
        table.isHidden = true
        isSearching = false
        logoutButton.title = "Logout"

    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.showsCancelButton = false
        table.isHidden = true
        isSearching = false
        logoutButton.title = "Logout"

    }
    func setupSearchBar (){
        
        let frame = CGRect(x: -20, y: 2, width: self.view.frame.width - 100, height: 44)
        let titleView = UIView(frame: frame)
        let searchBar = UISearchBar(frame: frame)
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.delegate = self
        titleView.addSubview(searchBar)
        navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: titleView)
        
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
        
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            annotationView.canShowCallout = true
            
            let aTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            
            aTextView.text = annotation.subtitle!
            aTextView.font = UIFont.systemFont(ofSize: 13)
            aTextView.textColor = UIColor.darkGray
            aTextView.isEditable = false
            annotationView.detailCalloutAccessoryView = aTextView;
            
            let width = NSLayoutConstraint(item: aTextView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
            aTextView.addConstraint(width)
            let height = NSLayoutConstraint(item: aTextView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 90)
            aTextView.addConstraint(height)


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
                        
                        let user : NSDictionary = ["username" : username, "latitude" : latitude, "longitude" : longitude, "text" : text ]
                        self.notesArray.append(user)

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
                    
                    let locationNote = lastAddedItem.value as? [String : AnyObject]
                    let longitude = locationNote?["longitude"] as! CLLocationDegrees
                    let latitude = locationNote?["latitude"] as! CLLocationDegrees
                    let text = locationNote?["text"] as! String
                    
                    let user : NSDictionary = ["username" : username, "latitude" : latitude, "longitude" : longitude, "text" : text ]
                    self.notesArray.append(user)
                    
                    self.addNoteToMap(lat: latitude, long: longitude, title: username, text: text)
                    print("Added a new note!")
                
                }
            }

        } )
        

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user : NSDictionary?
        
        user = filteredNotesArray[indexPath.row]
        
        let longitude = user?["longitude"] as! CLLocationDegrees
        let latitude = user?["latitude"] as! CLLocationDegrees
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let title = user?["username"] as! String
        let latDelta: CLLocationDegrees = 0.004
        let lonDelta: CLLocationDegrees = 0.004
        
        let span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        self.map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        //create a temp list of annotations filtered by the first candidate
        let index = map.annotations.index { annotation in
            return (annotation.coordinate.isEqual(to: location) && annotation.title == title)
        }
        
        map.selectAnnotation(map.annotations[index!], animated: true)
        
        self.view.endEditing(true)
        table.reloadData()

        

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        //if user is searching return the filtered users by the text that the user wrote
        if isSearching {
            
            return filteredNotesArray.count
        }
        
        //else return all users or alternativley, no results at all
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        cell.layer.cornerRadius = 10
        
        let user : NSDictionary?
        
        user = filteredNotesArray[indexPath.row]
        cell.title.text = user?["username"] as? String
        cell.discription.text = user?["text"] as? String
        let longitude = user?["longitude"] as! CLLocationDegrees
        let latitude = user?["latitude"] as! CLLocationDegrees

        cell.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        return cell
    }
    
    func filterSearchResults (searchText : String){
        
        self.filteredNotesArray = self.notesArray.filter { user in
            
            let username = user!["username"] as? String
            let text = user!["text"] as? String
            if (username?.lowercased().contains(searchText.lowercased()))! {
                return true
            }
            
            return (text?.lowercased().contains(searchText.lowercased()))! 
        }
        
        table.reloadData()
    }
}

extension CLLocationCoordinate2D {
    
    func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
        
        if self.latitude != coordinate.latitude &&
            self.longitude != coordinate.longitude {
            return false
        }
        return true
    }
    
}

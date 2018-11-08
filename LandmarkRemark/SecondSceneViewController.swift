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
   
    //grabing the outlets from the interface builder
    @IBOutlet var logoutButton: UIBarButtonItem!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var map: MKMapView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var addNoteView: UIView!
    @IBOutlet var addNoteText: UITextView!
    @IBOutlet var table: UITableView!

    let locationManager = CLLocationManager()
    
    var isSearching = false
    //the array of notes to be searched in
    var notesArray = [NSDictionary?]()
    //the array of filterd notes to be displayed
    var filteredNotesArray = [NSDictionary?]()

    override func viewDidLoad() {
        super.viewDidLoad()

        //setting delegates
        map.delegate = self
        table.delegate = self
        table.dataSource = self
        navigationBar.delegate = self
        
        //configuring the location manager, UI elements, and search bar
        setupLocationManager()
        setUpUIelements()
        setupSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //check if connected to firebase database
        checkFirebaseConnection()
        //whenever the view appears load the existing notes to the map and expect new notes to be coming
        loadExistingAnnotations()
        observeNewLocationNotes()
        
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        
        //hide the add note view and hide the keyboard
        addNoteView.isHidden = true
        addNoteText.resignFirstResponder()
        
    }
    
    @IBAction func addNewNoteButtonClicked(_ sender: Any) {
        
        //show the new note view and show the keyboard
        addNoteView.isHidden = false
        addNoteText.text = ""
        addNoteText.becomeFirstResponder()
        
    }
    
    @IBAction func confirmAddingNoteClicked(_ sender: Any) {
        
        //get the values from the current user location and the text if they exist
        guard let latitude = locationManager.location?.coordinate.latitude else { return }
        guard let longitude = locationManager.location?.coordinate.longitude else { return }
        guard let text = addNoteText.text else { return }

        //if text is not empty
        if text != "" {
        //create a note and set the parameters
        let note = LocationNote(altitude: latitude, longitude: longitude, text: text)
        
        //save location note to the database
        saveLocationNote(note: note)
        //remove the new note view and hide the keyboard
        addNoteView.isHidden = true
        addNoteText.resignFirstResponder()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //get most recent location
        let currentLocation = locations[0]
        let myLocation = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        //values for the Deltas of the span
        let latDelta: CLLocationDegrees = 0.05
        let lonDelta: CLLocationDegrees = 0.05
        //Creating a span for the region
        let span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: myLocation, span: span)
        //set the visible region of the map
        self.map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
        self.locationManager.stopUpdatingLocation()

        
    }
    
    @IBAction func logoutClicked(_ sender: Any) {
        
        //logout user
        try! Auth.auth().signOut()
        //return to the parent view
        self.dismiss(animated: true)
        //remove all annotations
        let allAnnotations = self.map.annotations
        self.map.removeAnnotations(allAnnotations)
        //remove all notes and filtered notes
        notesArray.removeAll()
        filteredNotesArray.removeAll()
    }
    
    func setupLocationManager() {
        
        //configuring locaiton manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        //start updating the location asynchronously
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func setUpUIelements() {
    
    //setting UI elements
    addButton.layer.cornerRadius = addButton.bounds.size.height/2
    addButton.layer.shadowOffset = CGSize(width: -1, height: 1)
    addButton.layer.shadowOpacity = 0.2
    addNoteView.layer.cornerRadius = 10
    addNoteView.layer.shadowOffset = CGSize(width: -1, height: 1)
    addNoteView.layer.shadowOpacity = 0.2
    table.backgroundColor = UIColor.black.withAlphaComponent(0.5)

}
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
       //called when text changes in searchbar
        
        if searchBar.text == nil {
            //if search bar text has a no value
            self.view.endEditing(true)
            table.reloadData()
        }
        else {
            //if search bar text has a value
            isSearching = true
            //start filtering the table results of the search text
            filterSearchResults(searchText: searchText)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

        //if search icon is clicked
        //hide table and show cancel button and hide the logout button
        table.isHidden = false
        searchBar.showsCancelButton = true
        isSearching = true
        logoutButton.title = ""
    }
  
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // if cancel search button is clicked
        // unhide the items hidden
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.showsCancelButton = false
        table.isHidden = true
        isSearching = false
        logoutButton.title = "Logout"

    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //if text bar did end editing was called
        //unhide the hidden items
        searchBar.text = ""
        searchBar.showsCancelButton = false
        table.isHidden = true
        isSearching = false
        logoutButton.title = "Logout"
    }
    
    func setupSearchBar (){
        
        //setting up the search bar
        let frame = CGRect(x: -20, y: 2, width: self.view.frame.width - 100, height: 44)
        //creating a custom view of specific frame
        let titleView = UIView(frame: frame)
        let searchBar = UISearchBar(frame: frame)
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.delegate = self
        //adding the search bar to the view
        titleView.addSubview(searchBar)
        //adding the view to the left bar item of the navigtaion bar
        navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: titleView)
        
    }
    
    func saveLocationNote (note: LocationNote){
        
        //grab current user uid
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //set reference to db
        let reference = Database.database().reference().child("users/\(uid)/notes").childByAutoId()
        
        //create a dictionary to save the location note from the argument to the db
        let userData = [
            
            "longitude" : note.longitude,
            "latitude" : note.altitude,
            "text" : note.text
            
        ] as [String : Any]
        
        //save.
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
        
        let identifier = "somePin"
            //creating a custom annotation view
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        
            annotationView.canShowCallout = true
        
            //adding a text view to the annotation view to display user note text
            let aTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
            //adding values to text view from the annotation
            aTextView.text = annotation.subtitle!
            aTextView.font = UIFont.systemFont(ofSize: 13)
            aTextView.textColor = UIColor.darkGray
            aTextView.isEditable = false
            annotationView.detailCalloutAccessoryView = aTextView;
        
            //adding constraints to the textview
            let width = NSLayoutConstraint(item: aTextView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 200)
            aTextView.addConstraint(width)
            let height = NSLayoutConstraint(item: aTextView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 90)
            aTextView.addConstraint(height)

        return annotationView
    }
    
    func addNoteToMap(lat: CLLocationDegrees, long: CLLocationDegrees,title: String,text: String) {
        
                  //create a location
                  let location  = CLLocationCoordinate2D(latitude: lat, longitude: long)
                  //create an annotation
                  let annotation = MKPointAnnotation()
                  //configure annotation
                  annotation.coordinate = location
                  annotation.title = title
                  annotation.subtitle = text
                  //add annotation to map
                  map.addAnnotation(annotation)
        
                  let latDelta: CLLocationDegrees = 0.004
                  let lonDelta: CLLocationDegrees = 0.004
                  let span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                  let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        
                  //setting the map view to the added note's location
                  self.map.setRegion(region, animated: true)
    }
    
    func loadExistingAnnotations(){
        //grab a reference
        let reference = Database.database().reference()
        //observe the child "users" and get the FIREBASE Snapshot
        reference.child("users").observe(.childAdded) { snapshot in

            //loop through all the children of the snapshot
            for userData in snapshot.children.allObjects as! [DataSnapshot] {
                //save the username because its saved at this level of the hierarchy
                let username = (snapshot.value as? NSDictionary)?["username"] as? String ?? ""
                //if the child's key is 'notes' then go deeper and loop through it to get the values
                if userData.key == "notes" {
                   //loop through the notes
                    for notesData in userData.children.allObjects as! [DataSnapshot] {
                        //grab the values from the note as dictionary values
                        let locationNote = notesData.value as? [String : AnyObject]
                        let longitude = locationNote?["longitude"] as! CLLocationDegrees
                        let latitude = locationNote?["latitude"] as! CLLocationDegrees
                        let text = locationNote?["text"] as! String
                        //create a user to be saved to the notes array
                        let user : NSDictionary = ["username" : username, "latitude" : latitude, "longitude" : longitude, "text" : text ]
                        self.notesArray.append(user)
                        //add the found note to the map
                        self.addNoteToMap(lat: latitude, long: longitude, title: username, text: text)
                        print("Added an existing annotation")
                    }
                }
            }
        }
    }
    
    func observeNewLocationNotes(){
        
        //database reference
        let reference = Database.database().reference().child("users/")
        //observe the reference for any child change, and we expect each logged in user to add new notes so this gets called
        reference.observe(.childChanged, with: { (snapshot : DataSnapshot) in
            
            for userData in snapshot.children.allObjects as! [DataSnapshot] {
                //save the username because its saved at this level of the hierarchy
                let username = (snapshot.value as? NSDictionary)?["username"] as? String ?? ""
                //if the child's key is 'notes' then go there
                if userData.key == "notes" {
                   
                    //get the last added item
                    let lastAddedItem = userData.children.allObjects.last as! DataSnapshot
                    //grab the values from the note as dictionary values
                    let locationNote = lastAddedItem.value as? [String : AnyObject]
                    let longitude = locationNote?["longitude"] as! CLLocationDegrees
                    let latitude = locationNote?["latitude"] as! CLLocationDegrees
                    let text = locationNote?["text"] as! String
                    //create a user to be saved to the notes array
                    let user : NSDictionary = ["username" : username, "latitude" : latitude, "longitude" : longitude, "text" : text ]
                    self.notesArray.append(user)
                    //add the found note to the map
                    self.addNoteToMap(lat: latitude, long: longitude, title: username, text: text)
                    print("Added a new note!")
                
                }
            }

        } )
        

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //when a row is selected
        //create a user
        let user : NSDictionary?
        
        //set user value from the call of filteredNotes
        user = filteredNotesArray[indexPath.row]
        
        //setting location values from the user
        let longitude = user?["longitude"] as! CLLocationDegrees
        let latitude = user?["latitude"] as! CLLocationDegrees
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let title = user?["username"] as! String
        let latDelta: CLLocationDegrees = 0.004
        let lonDelta: CLLocationDegrees = 0.004
        let span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        
        //setting the map view to the selected note's location
        self.map.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        //create a temp list of annotations filtered by the best matching location and title to make sure its the correct note
        let index = map.annotations.index { annotation in
            return (annotation.coordinate.isEqual(to: location) && annotation.title == title)
        }
        //select the note which calls the view of the note to expand
        map.selectAnnotation(map.annotations[index!], animated: true)
        //remove the keyboard, the table and unhide the hidden elements
        self.view.endEditing(true)
        table.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        //if user is searching return the filtered users by the text that the user wrote
        if isSearching {
            return filteredNotesArray.count
        }
        //else return no results at all
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get the cell and configure it
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        cell.layer.cornerRadius = 10
        
        //create a user
        let user : NSDictionary?
        //get a user based on the filtered results
        user = filteredNotesArray[indexPath.row]
        //grab location from user
        let longitude = user?["longitude"] as! CLLocationDegrees
        let latitude = user?["latitude"] as! CLLocationDegrees
        //set cell's properties
        cell.title.text = user?["username"] as? String
        cell.discription.text = user?["text"] as? String
        cell.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        return cell
    }
    
    func filterSearchResults (searchText : String){
        
        //set the filtered notes array to the non filtered notes array with is  using a filtering closure
        self.filteredNotesArray = self.notesArray.filter { user in
            
            let username = user!["username"] as? String
            let text = user!["text"] as? String
            //get username and text from user
            
            //return true if the username has the search results
            if (username?.lowercased().contains(searchText.lowercased()))! {
                return true
            }
            //also true if the text has the search results
            return (text?.lowercased().contains(searchText.lowercased()))!
        }
        //refresh table data
        table.reloadData()
    }
    
    //checking firebase connection function
    private func isConnected(completionHandler : @escaping (Bool) -> ()) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            completionHandler((snapshot.value as? Bool)!)
        })
    }
    
    private func checkFirebaseConnection(){
        isConnected { connected in
            if(connected){
                //nothing to be done
            } else {
                self.showAlert(title: "No Internet Connection", message: "Please connect to the internet to read and post notes.")
            }
        }
    }
    
    //creating an alert-posting-function
    func showAlert (title: String, message : String) {
        
        //create alert
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        //add action to alert
        alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
        //present alert
        self.present(alert,animated: true, completion : nil)
    }
    
}

//an extention to CLLocationCoordinate to add the equality checker function
//to be used in when clicking the notes in the search and finding the cooresponding note in the mapView
extension CLLocationCoordinate2D {
    
    func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
        
        if self.latitude != coordinate.latitude &&
            self.longitude != coordinate.longitude {
            return false
        }
        return true
    }
    
}

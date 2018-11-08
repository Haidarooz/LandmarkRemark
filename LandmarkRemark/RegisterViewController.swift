//
//  RegisterViewController.swift
//  LandmarkRemark
//
//  Created by Haidar Mohammed on 3/11/18.
//  Copyright © 2018 Haidar AlOgaily. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class RegisterViewController: UIViewController {

    //Interface builder outlets
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var usernameText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var errorLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
    }
    
    
    fileprivate func configureButtons() {
        //configure buttons and page title
        registerButton.backgroundColor = UIColor.white
        registerButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        registerButton.layer.shadowOpacity = 0.2
        registerButton.layer.cornerRadius = 15
        self.title = "Registration"
    }
    
    @IBAction func registerClicked(_ sender: Any) {
        //get email and password if they exist
        guard let email = emailText.text else {return}
        guard let password = passwordText.text else {return}
        
        //check if username is not empty and matches the chriteria of less or equal to 12 characters
        if !(usernameText.text?.isEmpty)! && (usernameText.text!.count < 13) {

        //create user with the credentials
        Auth.auth().createUser(withEmail: email, password: password) { user,error in
            
            //if no errors and user exist

            if error == nil && user != nil {
                print("User creation = OK")
                
                //grab the userID (uid) and username if they exist
                guard let uid = Auth.auth().currentUser?.uid else { return }
                guard let username = self.usernameText.text else { return }
                
                //grab a reference of the database
                let reference = Database.database().reference().child("users/\(uid)")
                
                //save the username as a dictonary to the corresponding uid
                let dataToSave = ["username" : username]
                reference.setValue(dataToSave) { error, ref in
                    
                    if error != nil {
                        print(error!.localizedDescription)
                    }
                }
                //go back to the MainScene and then it'll check if user is signed then takes you to the map page
                self.navigationController!.popViewController(animated: true)

            }
            else{
                //if an error occured then print it in the console and to the user
                print("An error has occured: \(error!.localizedDescription)")
                self.errorLabel.text = error!.localizedDescription
            }
        }
    }
        else {
            //user didnt enter correct username or username format
            self.errorLabel.text = "Enter a username that is less than 12 Characters"
        }
    }
    

}

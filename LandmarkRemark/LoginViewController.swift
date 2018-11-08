//
//  LoginViewController.swift
//  LandmarkRemark
//
//  Created by Haidar Mohammed on 3/11/18.
//  Copyright © 2018 Haidar AlOgaily. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    //Interface builder outlets
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConfigureButtons()

    }
    
    fileprivate func ConfigureButtons() {
        
        //configure the buttons and title of the page
        loginButton.backgroundColor = UIColor.white
        loginButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        loginButton.layer.shadowOpacity = 0.2
        loginButton.layer.cornerRadius = 15
        self.title = "Login"
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        
        //grab the email and user name if they exist else return
        guard let email = emailText.text else {return}
        guard let password = passwordText.text else {return}
        
        //signIn call
        Auth.auth().signIn(withEmail: email, password: password) { user,error in
            
            //if no errors and user exist
            if error == nil && user != nil {
                print("Logging in")
                //go back to the MainScene and then it'll check if user is signed then takes you to the map page
                self.navigationController!.popViewController(animated: true)
            } else{
                
                //if an error occured then print it in the console and to the user
                print("Error: \(error!.localizedDescription)")
                self.errorLabel.text = error!.localizedDescription
            }
            
        }
        
        
    }
    
}

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

    @IBOutlet var registerButton: UIButton!
    @IBOutlet var usernameText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.backgroundColor = UIColor.white
        registerButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        registerButton.layer.shadowOpacity = 0.2
        registerButton.layer.cornerRadius = 15
        self.title = "Registration"
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        

    }
    
    
    @IBAction func registerClicked(_ sender: Any) {
        //get email and password if they exist
        guard let email = emailText.text else {return}
        guard let password = passwordText.text else {return}
        
        if !(usernameText.text?.isEmpty)! && (usernameText.text!.count < 13) {

        //create user with the credentials
        Auth.auth().createUser(withEmail: email, password: password) { user,error in
            
            //if no errors
            
            if error == nil && user != nil {
                print("User creation = OK")
                guard let uid = Auth.auth().currentUser?.uid else { return }
                guard let username = self.usernameText.text else { return }
                
                let reference = Database.database().reference().child("users/\(uid)")
                let dataToSave = ["username" : username]
                reference.setValue(dataToSave) { error, ref in
                    
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                }
                
                self.navigationController!.popViewController(animated: true)

            }
            else{
            //if theres an error
                print("An error has occured: \(error!.localizedDescription)")
                self.errorLabel.text = error!.localizedDescription
            }
        }
    }
        else {
            
            self.errorLabel.text = "Enter a username that is less than 12 Characters"
        }
    }
    

}

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

    
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.backgroundColor = UIColor.white
        loginButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        loginButton.layer.shadowOpacity = 0.2
        loginButton.layer.cornerRadius = 15
        self.title = "Login"

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        guard let email = emailText.text else {return}
        guard let password = passwordText.text else {return}
        
        
        Auth.auth().signIn(withEmail: email, password: password) { user,error in
            
            if error == nil && user != nil {
                print("Logging in")
                self.navigationController!.popViewController(animated: true)
            }else {
                print("Error: \(error!.localizedDescription)")
                self.errorLabel.text = error!.localizedDescription
            }
            
        }
        
        
    }
    
}

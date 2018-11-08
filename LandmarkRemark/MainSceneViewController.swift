//
//  ViewController.swift
//  LandmarkRemark
//
//  Created by Haidar Mohammed on 2/11/18.
//  Copyright © 2018 Haidar AlOgaily. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainSceneViewController: UIViewController {
    
    //Interface builder outlets
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //setting back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: nil, action: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        configureButtons()
        
        //if user was logged previously in then go the map scene
        if let user = Auth.auth().currentUser {
            self.performSegue(withIdentifier: "toSecondScene", sender: self)
        }
        
    }
    
    fileprivate func configureButtons() {
        
        //configuring buttons
        registerButton.backgroundColor = UIColor.white
        registerButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        registerButton.layer.shadowOpacity = 0.2
        registerButton.layer.cornerRadius = 20
        loginButton.backgroundColor = UIColor.white
        loginButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        loginButton.layer.shadowOpacity = 0.2
        loginButton.layer.cornerRadius = 20
    }
    
    @IBAction func registerButtonClicked(_ sender: Any) {
        //go to the registeration page is the button is clicked
        self.performSegue(withIdentifier: "register", sender: self)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
        //go to the login page is the button is clicked
          self.performSegue(withIdentifier: "login", sender: self)
    }
    
}


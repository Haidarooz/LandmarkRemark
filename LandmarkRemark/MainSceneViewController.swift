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
    
    @IBOutlet var loginButton: UIButton!
    
    @IBOutlet var registerButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: nil, action: nil)

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        registerButton.backgroundColor = UIColor.white
        registerButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        registerButton.layer.shadowOpacity = 0.2
        registerButton.layer.cornerRadius = 20
        loginButton.backgroundColor = UIColor.white
        loginButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        loginButton.layer.shadowOpacity = 0.2
        loginButton.layer.cornerRadius = 20
        if let user = Auth.auth().currentUser {
            self.performSegue(withIdentifier: "toSecondScene", sender: self)
        }
        
    }
    @IBAction func registerButtonClicked(_ sender: Any) {
        
        self.performSegue(withIdentifier: "register", sender: self)
    }
    
    @IBAction func loginButtonClicked(_ sender: Any) {
          self.performSegue(withIdentifier: "login", sender: self)
    }
    
}


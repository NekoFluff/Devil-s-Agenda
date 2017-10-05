//
//  ViewController.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/3/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LogInViewController : UIViewController, GIDSignInUIDelegate {
    
    var handle : AuthStateDidChangeListenerHandle?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self;
        GIDSignIn.sharedInstance().signInSilently();
        
        handle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            if let user = user {
                
                self.addUser(user: user);
                
                //MeasurementHelper.sendLoginEvent()
                self.performSegue(withIdentifier: Constants.Segues.SignIn, sender: nil)
            }
        }
        
    }
    
    func addUser(user : User) {
        let ref = Database.database().reference()
        ref.child("users").child(user.uid).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if !snapshot.exists() {
                ref.child("users").child(user.uid).setValue(["username": user.displayName])
                print("Added first time user: " + (user.displayName ?? "ERROR_NULL_DISPLAY_NAME"))
            }
            
        }, withCancel: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}


//
//  SettingsViewController.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 11/22/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class SettingsViewController: UIViewController {
    let database = DatabaseManager.defaultManager
    
    @IBAction func signOut(_ sender: UIButton) {
        do {
            database.removeAllListeners()
            
            try Auth.auth().signOut();
            GIDSignIn.sharedInstance().signOut();
            self.database.signOut();
            
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

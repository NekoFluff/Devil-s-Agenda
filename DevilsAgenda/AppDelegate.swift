//
//  AppDelegate.swift
//  Devil's Agenda
//
//  Created by Alexander Nou on 9/3/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    // Notification Center
    
    let center = UNUserNotificationCenter.current()
    
    let notificationDelegate = NotificationDelegate()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        FirebaseApp.configure();
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID;
        GIDSignIn.sharedInstance().delegate = self;
        
        
        // Notification Authorization
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if !granted {
                print("Authorization Denied")
            }
            
        self.center.delegate = self.notificationDelegate
            
        }
        
        
        
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            return GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            print(error);
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user,error) in
            if let error = error {
                // handle error
                print(error);
                return
            }
            //User is signed in
        }
        // ...
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
        center.getNotificationSettings { (settings) in
            
            if settings.authorizationStatus == .authorized {
                
                
                // Set Up Notification Parameters:
                
                //indentifier:
                let identifier = "FiveMinuteTimerNotification"
                
                //actions:
                let snoozeAction = UNNotificationAction(identifier: "SnoozeAction", title: "Snooze", options: [])
                let taskCompleteAction = UNNotificationAction(identifier: "TaskCompleteAction", title: "Mark Completed", options: [])
                
                //category:
                let category = UNNotificationCategory(identifier: "ReminderCategory", actions: [snoozeAction, taskCompleteAction], intentIdentifiers: [], options: [])
                self.center.setNotificationCategories([category])
                
                //content:
                let content = UNMutableNotificationContent()
                content.title = "It's been 5 minutes!"
                content.body = "Ring-a-ding-ding"
                content.sound = UNNotificationSound.default()
                content.categoryIdentifier = "ReminderCategory"
                
                //trigger:
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                
                // Schedule notification:
                
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                
                // Add notification to center:
                
                self.center.add(request, withCompletionHandler: { (error) in
                    if error != nil {
                        //Something's wrong yo
                    }
                })
            }
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    //Notification Function:
    
    func setDateNotification(category: UNNotificationCategory, request: UNNotificationRequest) -> Void {
        
        print("Adding Notification to center")
        center.setNotificationCategories([category])
        
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                //Something's wrong yo
                print("oh no")
            }
        })
        
        print("Content: \(request.content)")
        
        center.getPendingNotificationRequests(){[unowned self] requests in
            for request in requests {
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger else {return}
                print(Calendar.current.dateComponents([.year,.day,.month,.hour,.minute,.second], from: trigger.nextTriggerDate()!))
            }
        }
        
    }
}


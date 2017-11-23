//
//  LoadingViewController.swift
//  DevilsAgenda
//
//  Created by Alexander Nou on 11/7/17.
//  Copyright © 2017 Team PlanIt. All rights reserved.
//

import UIKit
import Lottie

class LoadingViewController: UIViewController {

    @IBAction func buttonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: Constants.Segues.FinishedLoading, sender: self)
    }
    
    var animationView : LOTAnimationView!
    var topText : UILabel!
    var bottomText : UILabel!
    let database = DatabaseManager.defaultManager
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAnimation()
        
        var follow = false;
        var local = false;
        
        database.downloadClasses { [weak self] (current, max, checkedFollowedClasses, checkedLocalClasses) in
            print("Download Progress: \(current)\\\(max)")
            
            if let strongSelf = self {
                strongSelf.topText.text = "Downloading your classes (\(current)/\(max))"
                
                
                if checkedFollowedClasses {
                    follow = true
                }
                if checkedLocalClasses {
                    local = true
                }
                if (current >= max && follow && local) { //Checked both followed and local classes (Prevents double segue)
                    
                    print("Segue in 2 seconds...")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2, execute: {
                        //Reset
                        follow = false
                        local = false
                        
                        strongSelf.performSegue(withIdentifier: Constants.Segues.FinishedLoading, sender: strongSelf)
                    })
                }
            } else {
                print("ERROR: Strong SELF does not exist for LoadingViewController")
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addAnimation() {
        
        //MIDDLE ANIMATION
        let animationHeight : CGFloat = self.view.frame.width*4/5;
        
        animationView = LOTAnimationView(name: "animation-w200-h200");
        animationView.contentMode = .scaleAspectFit;
        let animationWidth = self.view.frame.width
        animationView.frame = CGRect(x: 0, y: self.view.frame.size.height/2 - animationHeight/2, width: animationWidth, height: animationHeight);
        animationView.loopAnimation = true;
        self.view.addSubview(animationView);
        
        //TOP TEXT
        topText = UILabel(frame: CGRect(x: 0, y: animationView.frame.minY-25, width: self.view.frame.size.width, height: 30))
        topText.textAlignment = NSTextAlignment.center
        topText.text = "Downloading your classes (0/0)"
        topText.textColor = UIColor(colorLiteralRed: 255/255, green: 197/255, blue: 85/255, alpha: 1)
        self.view.addSubview(topText);
        
        //BOTTOM TEXT
        bottomText = UILabel(frame: CGRect(x: 0, y: animationView.frame.maxY+15, width: self.view.frame.size.width, height: 30))
        bottomText.textAlignment = NSTextAlignment.center
        bottomText.text = "Please wait..."
        bottomText.textColor = UIColor(colorLiteralRed: 255/255, green: 197/255, blue: 85/255, alpha: 1)
        self.view.addSubview(bottomText);
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

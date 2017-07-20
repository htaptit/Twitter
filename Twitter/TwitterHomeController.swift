//
//  ViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/5/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import TwitterKit
import TwitterCore

class TwitterHomeController: UIViewController {

    @IBOutlet weak var descriptonLable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptonLable.lineBreakMode = .byWordWrapping
        descriptonLable.numberOfLines = 0
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        if checkIsLogin() {
//            let timelineView = self.storyboard?.instantiateViewController(withIdentifier: "timeline") as! TimelineControllerViewController
//            self.navigationController?.pushViewController(timelineView, animated: false)
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            
            let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "tabBar")
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        }
    }
    
    func checkIsLogin() -> Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
//                let timelineView = self.storyboard?.instantiateViewController(withIdentifier: "timeline") as! TimelineControllerViewController
//                self.navigationController?.pushViewController(timelineView, animated: true)
                let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                
                let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "tabBar")
                appDelegate.window?.rootViewController = initialViewController
                appDelegate.window?.makeKeyAndVisible()
            } else {
                print("error: \(String(describing: error?.localizedDescription))")
            }
        })
    }
    
}


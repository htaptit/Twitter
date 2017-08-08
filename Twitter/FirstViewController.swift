//
//  FirstViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 8/8/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import TwitterKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        //        self.tabBarController?.tabBar.isHidden = true
        let when = DispatchTime.now() + 5
        DispatchQueue.main.asyncAfter(deadline: when, execute: {
            if self.isLogged() {
                let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                
                let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "barTimeline")
                appDelegate.window?.rootViewController = initialViewController
                appDelegate.window?.makeKeyAndVisible()
            } else {
                let twitterHomeVC = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as? TwitterHomeController
                self.navigationController?.pushViewController(twitterHomeVC!, animated: true)
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func isLogged() -> Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }

}

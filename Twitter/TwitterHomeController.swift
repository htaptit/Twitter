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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
//                print("signed in as \(String(describing: session?.userName))")
                let timelineView = self.storyboard?.instantiateViewController(withIdentifier: "timeline") as! TimelineControllerViewController
                self.navigationController?.pushViewController(timelineView, animated: true)
//                self.present(timelineView, animated: true, completion: nil)
            } else {
                print("error: \(String(describing: error?.localizedDescription))")
            }
        })
    }
    
}


//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/14/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit


class TweetDetailViewController: UIViewController {
    
    var tweet: TwitterData!
    
    @IBOutlet weak var topView: TweetView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewTweet() {
        
    }
}

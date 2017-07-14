//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/14/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit


class TweetDetailViewController: UIViewController{
    
    var tweet: TwitterData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("tweet \(tweet)")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func doSomething(with data: Int) {
//        print(data)
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "detailTweet" {
//            let timeline: TimelineControllerViewController = segue.destination as! TimelineControllerViewController
//            timeline.delegate = self
//        }
//    }

}

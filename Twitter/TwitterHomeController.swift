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
extension Notification.Name {
    static let retweetOrQuote = Notification.Name("retweetOrQuote")
}
class TwitterHomeController: UIViewController {

    @IBOutlet weak var descriptonLable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(retweetOrQuote(_:)), name: .retweetOrQuote, object: nil)
        descriptonLable.lineBreakMode = .byWordWrapping
        descriptonLable.numberOfLines = 0
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        if isLogged() {
            let appDelegate = UIApplication.shared.delegate! as! AppDelegate
            
            let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "barTimeline")
            appDelegate.window?.rootViewController = initialViewController
            appDelegate.window?.makeKeyAndVisible()
        }
        
        
    }
    
    func isLogged() -> Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        Twitter.sharedInstance().logIn(completion: { (session, error) in
            if (session != nil) {
                let appDelegate = UIApplication.shared.delegate! as! AppDelegate
                
                let initialViewController = self.storyboard!.instantiateViewController(withIdentifier: "barTimeline")
                appDelegate.window?.rootViewController = initialViewController
                appDelegate.window?.makeKeyAndVisible()
            } else {
                print("error: \(String(describing: error?.localizedDescription))")
            }
        })
    }
    
    @objc func retweetOrQuote(_ notification: Notification) {
        print(notification)
        //        if let buttonID = notification.object as? String {
        //            let arr = buttonID.splitStringToArray(separator: "_")
        //            let tweetID = String(describing: arr[1])
        //            let at = Int(String(describing: arr[2]))
        //            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        //            switch self.tweets[at!].isRetweeted {
        //            case true:
        //                actionSheet.addAction(UIAlertAction(title: "Un-retweet", style: .default, handler: { (action) in
        //                    self.un_retweet(tweetID, at!)
        //                }))
        //            case false:
        //                actionSheet.addAction(UIAlertAction(title: "Retweet", style: .default, handler: { (action) in
        //                    self.retweet(tweetID, at!)
        //                }))
        //
        //                actionSheet.addAction(UIAlertAction(title: "Quote tweet", style: .default, handler: { (action) in
        //
        //                }))
        //            }
        //
        //            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //
        //            self.present(actionSheet, animated: true, completion: nil)
        //        }
    }
    
    func retweet(_ tweetID: String, _ at: Int) {
        //        let url = TwitterAPI.TwitterUrl(method: .POST, path: .retweet_by_id, twitterUrl: .api, parameters: ["id": tweetID])
        //        TwitterAPI.postNewTweet(user: nil, url: url, result: { (data) in
        //            let userIDRetweeted = data.getUserID
        //            let currentUserID = Twitter.sharedInstance().sessionStore.session()?.userID
        //            if "\(userIDRetweeted)" == currentUserID && userIDRetweeted == data.userID_retweet {
        //                self.tweets.remove(at: at)
        //                self.tweets.insert(data, at: 0)
        //            } else {
        //                self.tweets[at].retweetCount = data.retweetCount
        //            }
        //
        //            //  let image = UIImage(named: "retweeted")
        //            //  button.setImage(image, for: UIControlState.normal)
        //            self.timeLineUITableView.reloadData()
        //        }) { (error) in
        //            print(error.localizedDescription)
        //        }
    }
    
    func un_retweet(_ tweetID: String,_ at: Int) {
        //        let url = TwitterAPI.TwitterUrl(method: .POST , path: .unretweet_by_id , twitterUrl: .api, parameters: ["id": tweetID])
        //        TwitterAPI.postNewTweet(user: nil, url: url, result: { (data) in
        //            self.tweets.remove(at: at)
        //            self.timeLineUITableView.reloadData()
        //        }) { (error) in
        //            print(error)
        //        }
    }

    
}


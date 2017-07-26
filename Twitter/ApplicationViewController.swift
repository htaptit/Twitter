//
//  ApplicationViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/25/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import TwitterKit
//import TwitterCore

class ApplicationViewController: UIViewController {
    
    var userID: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func updateToTwitter(_ tweet: TwitterData,_ VC : UIViewController,_ action: String,_ result: @escaping (TwitterData) -> (),_ error: @escaping (Error) -> ()) {
        if action == "RT" {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            switch tweet.isRetweeted {
            case true:
                actionSheet.addAction(UIAlertAction(title: "Un-retweet", style: .default, handler: { (action) in
                    let url = TwitterAPI.TwitterUrl(method: .POST, path: .unretweet_by_id, twitterUrl: .api, parameters: ["id": tweet.getTweetID])
                    TwitterAPI.postNewTweet(url: url, result: { (data) in
                        result(data)
                    }) { (err) in
                        error(err)
                    }
                }))
            case false:
                actionSheet.addAction(UIAlertAction(title: "Retweet", style: .default, handler: { (action) in
                    let url = TwitterAPI.TwitterUrl(method: .POST , path: .retweet_by_id , twitterUrl: .api, parameters: ["id": tweet.getTweetID])
                    TwitterAPI.postNewTweet(url: url, result: { (data) in
                        result(data)
                    }) { (err) in
                        error(err)
                    }
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Quote tweet", style: .default, handler: { (action) in
                    let quoteVC = VC.storyboard?.instantiateViewController(withIdentifier: "quoteView") as? QuoteViewController
                    quoteVC?.tweet = tweet
                    VC.navigationController?.pushViewController(quoteVC!, animated: true)
                }))
            }
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            if VC.presentedViewController == nil {
                VC.present(actionSheet, animated: true, completion: nil)
            }
        } else {
            var url: URLRequest? = nil
            if tweet.isFavorited {
                url = TwitterAPI.TwitterUrl(method: .POST, path: .favorites_destroy, twitterUrl: .api, parameters: ["id": tweet.getTweetID])
            } else {
                url = TwitterAPI.TwitterUrl(method: .POST, path: .favorites_create, twitterUrl: .api, parameters: ["id": tweet.getTweetID])
            }
            
            TwitterAPI.postNewTweet(url: url!, result: { (data) in
                result(data)
            }, error: { (err) in
                error(err)
            })
        }
    }
    
    private class func isLogged() -> Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }
    
    class func loadTweet(_ path: Path ,_ result: @escaping ([TwitterData]) -> (),_ error: @escaping (Error) -> ()) {
        if isLogged() {
            let url = TwitterAPI.TwitterUrl(method: .GET, path: path, twitterUrl: .api, parameters: ["screen_name": "htaptit", "count": "200"])
            TwitterAPI.getHomeTimeline(url: url, tweets: { (data) in
                if !data.isEmpty {
                    result(data)
                }
            }, error: { (err) in
                error(err)
            })
        }
    }

}

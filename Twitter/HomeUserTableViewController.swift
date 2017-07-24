//
//  HomeUserTableViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/21/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import TwitterKit
import TwitterCore
import SDWebImage

class HomeUserTableViewController: UITableViewController {
    var tweets = [TwitterData]()
    @IBOutlet var userTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userTableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetTableViewCell")
        self.userTableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil), forCellReuseIdentifier: "QuoteTableViewCell")
        
        self.userTableView.estimatedRowHeight = 300
        self.userTableView.rowHeight = UITableViewAutomaticDimension
//        NotificationCenter.default.addObserver(self, selector: #selector(retweetOrQuote(_:)), name: .retweet_or_quote , object: nil)
        loadTweet()
    }
    
    func loadTweet() {
        let url = TwitterAPI.TwitterUrl(method: .GET, path: .user_timeline, twitterUrl: .api, parameters: ["screen_name": "htaptit", "count": "50"])
        TwitterAPI.getHomeTimeline(user: nil, url: url, tweets: { (data) in
                for item in data {
                    self.tweets.append(item)
                    self.userTableView.reloadData()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(retweetOrQuote(_:)), name: .retweet_or_quote , object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .retweet_or_quote, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tweets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellFormated = formartCellTwitter(self.tweets, indexPath)
        return cellFormated
    }

    
    func retweetOrQuote(_ notification: Notification) {
        if let object = notification.object as? [String: String]{
            let url = TwitterAPI.TwitterUrl(method: .GET, path: .statuses_show , twitterUrl: .api, parameters: ["id": object["tweet_id"]!])
            TwitterAPI.get(user: nil, url: url, tweets: { (data) in
                let action = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                switch data.isRetweeted {
                case true:
                    action.addAction(UIAlertAction(title: "Un-retweet", style: .default, handler: { (action) in
                        self.un_retweet(object["tweet_id"]!, Int(object["index"]!)!)
                    }))
                case false:
                    action.addAction(UIAlertAction(title: "Retweet", style: .default, handler: { (action) in
                        self.retweet(object["tweet_id"]!, Int(object["index"]!)!)
                    }))
                    
                    action.addAction(UIAlertAction(title: "Quote tweet", style: .default, handler: { (action) in
                        let quoteVC = self.storyboard?.instantiateViewController(withIdentifier: "quoteView") as? QuoteViewController
                        let at = Int(object["index"]!)
                        quoteVC?.tweet = self.tweets[at!]
                        self.navigationController?.pushViewController(quoteVC!, animated: true)
                    }))
                }
                
                action.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                if self.presentedViewController == nil {
                    self.present(action, animated: true, completion: nil)
                }
            }, error: { (error) in
                print(error.localizedDescription)
            })
            
            
        }
    }
    
    func retweet(_ tweetID: String, _ at: Int) {
        let url = TwitterAPI.TwitterUrl(method: .POST, path: .retweet_by_id, twitterUrl: .api, parameters: ["id": tweetID])
        TwitterAPI.postNewTweet(user: nil, url: url, result: { (data) in
            let userIDRetweeted = data.getUserID
            let currentUserID = Twitter.sharedInstance().sessionStore.session()?.userID
            if "\(userIDRetweeted)" == currentUserID && userIDRetweeted == data.userID_retweet {
                self.tweets.remove(at: at)
                self.tweets.insert(data, at: 0)
            } else {
                self.tweets[at].retweetCount = data.retweetCount
            }
            
            //  let image = UIImage(named: "retweeted")
            //  button.setImage(image, for: UIControlState.normal)
            self.userTableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func un_retweet(_ tweetID: String,_ at: Int) {
        let url = TwitterAPI.TwitterUrl(method: .POST , path: .unretweet_by_id , twitterUrl: .api, parameters: ["id": tweetID])
        TwitterAPI.postNewTweet(user: nil, url: url, result: { (data) in
            self.tweets.remove(at: at)
            self.userTableView.reloadData()
        }) { (error) in
            print(error)
        }
    }
}


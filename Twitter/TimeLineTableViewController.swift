//
//  TimeLineTableViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/21/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import TwitterKit
import TwitterCore
import SDWebImage

class TimeLineTableViewController: UITableViewController {
    var tweets = [TwitterData]()
    
    @IBOutlet weak var timeLineUITableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeLineUITableView.delegate = self
        self.timeLineUITableView.translatesAutoresizingMaskIntoConstraints = false
        self.tabBarController?.tabBar.isHidden = false
        
        self.timeLineUITableView.estimatedRowHeight = 300
        self.timeLineUITableView.rowHeight = UITableViewAutomaticDimension
        
        self.timeLineUITableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil) , forCellReuseIdentifier: "TweetTableViewCell")
        self.timeLineUITableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil), forCellReuseIdentifier: "QuoteTableViewCell")
        self.loadTweet()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(retweetOrQuote(_:)), name: .retweet_or_quote , object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(retweetOrQuote(_:)), name: .retweet_or_quote , object: nil)
        self.navigationController?.isNavigationBarHidden = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.newTweet != nil {
            tweets.insert(appDelegate.newTweet!, at: 0)
            timeLineUITableView.reloadData()
            appDelegate.newTweet = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .retweet_or_quote, object: nil)
    }
    
    func loadTweet() {
        if isLogged() {
            let url = TwitterAPI.TwitterUrl(method: .GET, path: .home_timeline, twitterUrl: .api, parameters: ["screen_name": "htaptit", "count": "50"])
            TwitterAPI.getHomeTimeline(user: nil, url: url, tweets: { (data) in
                if !data.isEmpty {
                    for tweet in data {
                        self.tweets.append(tweet)
                    }
                    self.timeLineUITableView.reloadData()
                }
            }, error: { (error) in
                print(error.localizedDescription)
            })
        }
    }
    
    func isLogged() -> Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }
    
    func retweetOrQuote(_ notification: Notification) {
        if let object = notification.object as? [String: String] {
            let url = TwitterAPI.TwitterUrl(method: .GET, path: .statuses_show , twitterUrl: .api, parameters: ["id": object["tweet_id"]!])
            TwitterAPI.get(user: nil, url: url!, tweets: { (data) in
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                switch data.isRetweeted {
                case true:
                    actionSheet.addAction(UIAlertAction(title: "Un-retweet", style: .default, handler: { (action) in
                        self.un_retweet(object["tweet_id"]!, Int(object["index"]!)!)
                    }))
                case false:
                    actionSheet.addAction(UIAlertAction(title: "Retweet", style: .default, handler: { (action) in
                        self.retweet(object["tweet_id"]!, Int(object["index"]!)!)
                    }))
                    
                    actionSheet.addAction(UIAlertAction(title: "Quote tweet", style: .default, handler: { (action) in
                        let quoteVC = self.storyboard?.instantiateViewController(withIdentifier: "quoteView") as? QuoteViewController
                        quoteVC?.tweet = self.tweets[Int(object["index"]!)!]
                        self.navigationController?.pushViewController(quoteVC!, animated: true)
                    }))
                }
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                if self.presentedViewController == nil {
                    self.present(actionSheet, animated: true, completion: nil)
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
            
            let indexPath = IndexPath(row: at, section: 0)
            self.timeLineUITableView.reloadRows(at: [indexPath], with: .automatic)
            
            self.timeLineUITableView.reloadData()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func un_retweet(_ tweetID: String,_ at: Int) {
        let url = TwitterAPI.TwitterUrl(method: .POST , path: .unretweet_by_id , twitterUrl: .api, parameters: ["id": tweetID])
        TwitterAPI.postNewTweet(user: nil, url: url, result: { (data) in
            self.tweets.remove(at: at)
            self.timeLineUITableView.reloadData()
        }) { (error) in
            print(error)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        tweets.removeAll()
        timeLineUITableView.reloadData()
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            Twitter.sharedInstance().sessionStore.logOutUserID(userID)
        }
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! TwitterHomeController
        self.navigationController?.pushViewController(loginVC, animated: false)
        
        
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweetDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "tweetDetail") as? TweetDetailViewController
        tweetDetailVC?.tweet = tweets[indexPath.row]
        self.navigationController?.pushViewController(tweetDetailVC!, animated: true)
    }

}


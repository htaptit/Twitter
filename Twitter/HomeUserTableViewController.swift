//
//  HomeUserTableViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/21/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import TwitterKit
//import TwitterCore
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
        
        ApplicationViewController.loadTweet(.user_timeline , { (tweet) in
            for item in tweet {
                self.tweets.append(item)
            }
            self.userTableView.reloadData()
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
        if let object = notification.object as? [String: String] {
            let row = Int(object["row"]!)
            ApplicationViewController.updateToTwitter(self.tweets[row!], self, { (data) in
                if self.tweets[row!].isRetweeted && !data.isRetweeted {
                    self.tweets.remove(at: row!)
                } else {
                    self.tweets.insert(data, at: 0)
                    self.tweets[row!].retweetCount = data.retweetCount
                }
                self.userTableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
}


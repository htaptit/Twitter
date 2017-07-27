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

class TimeLineTableViewController: UIViewController {
    var tweets = [TwitterData]()
    var path: Path?
    var menu: MenuViewController!
    
    @IBOutlet weak var timeLineUITableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timeLineUITableView.translatesAutoresizingMaskIntoConstraints = false
        self.tabBarController?.tabBar.isHidden = false
        
        self.timeLineUITableView.estimatedRowHeight = 300
        self.timeLineUITableView.rowHeight = UITableViewAutomaticDimension
        
        self.menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        
        ApplicationViewController.userShow({ (data) in
            self.menu.data = data
        }) { (err) in
            print(err.localizedDescription)
        }
        
        
        if let title = self.tabBarController?.tabBar.selectedItem?.title {
            self.path = title != "Timeline" ? .user_timeline : .home_timeline
            ApplicationViewController.loadTweet(self.path!, { (tweet) in
                for item in tweet {
                    self.tweets.append(item)
                }
                self.timeLineUITableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(openSideMenu(_:)), name: .open_menu, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.path = (self.tabBarController?.tabBar.selectedItem?.title).map { Path(rawValue: $0) }!
        
        NotificationCenter.default.addObserver(self, selector: #selector(retweetOrQuote(_:)), name: .to_twitter, object: nil)
        self.navigationController?.isNavigationBarHidden = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.newTweet != nil {
            tweets.insert(appDelegate.newTweet!, at: 0)
            timeLineUITableView.reloadData()
            appDelegate.newTweet = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .to_twitter, object: nil)
    }
    
    func retweetOrQuote(_ notification: Notification) {
        if let object = notification.object as? [String: String] {
            let row = Int(object["row"]!)!
            let indexPath: IndexPath = IndexPath(row: row, section: 0)
            
            ApplicationViewController.updateToTwitter(self.tweets[row], self, object["action"]!, { (data) in
                if object["action"]! == "RT" {
                    self.tweets[row].retweetCount = data.retweetCount
                    self.tweets[row].isRetweeted = data.isRetweeted
                } else {
                    self.tweets[row].favoriteCount = data.favoriteCount
                    self.tweets[row].isFavorited = data.isFavorited
                }
                
                self.timeLineUITableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    @IBOutlet weak var leadingLayoutContrain: NSLayoutConstraint!
    @IBOutlet weak var trainingLayoutConstraint: NSLayoutConstraint!
    var hideMenu = false
    @IBAction func openSideMenu(_ sender: Any) {
        let bound = UIScreen.main.bounds
        if hideMenu {
            self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 15, width: bound.width, height: 50)
            self.tabBarController?.tabBar.frame = CGRect(x: 0, y: bound.height - 50, width: bound.width, height: 50)
            trainingLayoutConstraint.constant = 0
            leadingLayoutContrain.constant = 0
            self.menu.view.removeFromSuperview()
        } else {
            let bound = UIScreen.main.bounds
            self.navigationController?.navigationBar.frame = CGRect(x: bound.width - 100, y: 15, width: bound.width, height: 50)
            self.tabBarController?.tabBar.frame = CGRect(x: bound.width - 100, y: bound.height - 50, width: bound.width, height: 50)
            trainingLayoutConstraint.constant = bound.width - 100
            leadingLayoutContrain.constant = 100 - bound.width
            self.menu.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.addChildViewController(menu)
            self.view.addSubview(self.menu.view)
        }
        
        hideMenu = !hideMenu
    }
    
    @IBAction func logout(_ sender: Any) {
        tweets.removeAll()
        timeLineUITableView.reloadData()
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            Twitter.sharedInstance().sessionStore.logOutUserID(userID)
        }
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! TwitterHomeController
        self.navigationController?.pushViewController(loginVC, animated: false)
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
}

extension TimeLineTableViewController: UITableViewDataSource, UITableViewDelegate  {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tbVC = UITableViewController()
        let cellFormated = tbVC.formartCellTwitter(self.tweets, indexPath, "timeline", tableView)
        return cellFormated
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweetDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "tweetDetail") as? TweetDetailViewController
        tweetDetailVC?.tweet = tweets[indexPath.row]
        self.navigationController?.pushViewController(tweetDetailVC!, animated: true)
    }
}


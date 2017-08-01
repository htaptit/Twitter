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

class TimeLineTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, UIScrollViewDelegate {
    var tweets = [TwitterData]()
    var path: Path?
    var menu: MenuViewController!
    
    @IBOutlet weak var timeLineUITableView: UITableView!
    @IBOutlet weak var leftBarItem: UIBarButtonItem!
    
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
            
            if self.path == .home_timeline {
                NotificationCenter.default.addObserver(self, selector: #selector(openSideMenu(_:)), name: .open_menu, object: nil)
            } else {
                self.navigationController?.navigationBar.isHidden = true
            }

            ApplicationViewController.loadTweet(self.path!, params: ["count": "50"], { (tweet) in
                for item in tweet {
                    self.tweets.append(item)
                }
                self.timeLineUITableView.reloadData()
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.path = (self.tabBarController?.tabBar.selectedItem?.title).map { Path(rawValue: $0) }!
        NotificationCenter.default.addObserver(self, selector: #selector(backToTimline), name: .back_timeline, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(retweetOrQuote(_:)), name: .to_twitter, object: nil)
        self.navigationController?.isNavigationBarHidden = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.newTweet != nil {
            tweets.insert(appDelegate.newTweet!, at: 0)
            timeLineUITableView.reloadData()
            appDelegate.newTweet = nil
        }
    }
    
    func backToTimline() {
//        let timelineVC = self.storyboard?.instantiateViewController(withIdentifier: "Timeline") as? TimeLineTableViewController
//        let homeVC = tabBarController?.selectedViewController
//        transition(from: homeVC!, to: timelineVC!, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
//            
//        }) { (abc: Bool) in
//            
//        }
        self.tabBarController?.selectedIndex = 0
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
                                        if data.isRetweeted == self.tweets[row].isRetweeted {
                        self.tweets[row].retweetCount -= 1
                        self.tweets[row].isRetweeted = false
                        if self.tabBarController?.selectedIndex == 1 {
                            self.tweets.remove(at: row)
                            self.timeLineUITableView.reloadData()
                        }
                    } else {
                        self.tweets[row].retweetCount = data.retweetCount
                        self.tweets[row].isRetweeted = data.isRetweeted
                    }
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
            self.navigationController?.navigationBar.frame = CGRect(x: bound.width - 100, y: 15, width: bound.width, height: 50)
            self.tabBarController?.tabBar.frame = CGRect(x: bound.width - 100, y: bound.height - 50, width: bound.width, height: 50)
            trainingLayoutConstraint.constant = bound.width - 100
            leadingLayoutContrain.constant = 100 - bound.width
            self.menu.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.addChildViewController(menu)
            self.view.addSubview(self.menu.view)
        }
        UIView.animate(withDuration: 0.3) { 
            self.view.layoutIfNeeded()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }
    var tep = 230
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let curentTab = self.tabBarController?.tabBar.selectedItem?.title!
        return CGFloat(curentTab != "Timeline" && self.menu.data != nil ? self.tep : 0)
    }

    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.register(UINib(nibName: "InformationUserTableViewCell", bundle: nil), forCellReuseIdentifier: "InformationUserTableViewCell")
        let header = tableView.dequeueReusableCell(withIdentifier: "InformationUserTableViewCell") as? InformationUserTableViewCell
        if self.menu.data == nil {
            return header!
        }
        header?.accountNameUILabel.text = self.menu.data.name
        header?.screenNameUILabel.text = "@\(self.menu.data.scname)"
        header?.descriptionUILabel.text = self.menu.data.description
        header?.currentLocationUILabel.text = self.menu.data.location
        header?.countFlowingUILabel.text = self.menu.data.followers_count
        header?.countFollwerUILabel.text = self.menu.data.friends_count
        header?.profileBackgroundUIImageView.sd_setImage(with: URL(string: self.menu.data.backgroundImage), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
        header?.avatartUIImageView.asCircle()
        header?.avatartUIImageView.sd_setImage(with: URL(string: self.menu.data.avt), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
        return header!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    // end : MARK: - Table view data source
    
    // Scroll
    var since_id: String? = nil,
    max_id: String? = nil
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !self.tweets.isEmpty {
            since_id = self.tweets[0].getTweetID
            let sid = Int(self.tweets[self.tweets.count - 1].getTweetID)! - 1
            max_id = String(sid)
        }
        let path: Path = self.tabBarController?.selectedIndex == 0 ? .home_timeline : .user_timeline
        var params: [String:String] = ["count": "200"]
        if scrollView.contentOffset.y <= 0 {
            
            params.updateValue(since_id!, forKey: "since_id")
            ApplicationViewController.loadTweet(path, params: params, { (data) in
                for tweet in data.reversed() {
                    self.tweets.insert(tweet, at: 0)
                }
                self.timeLineUITableView.reloadData()
            }, { (err) in
                print(err.localizedDescription)
            })
        }
        
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            params.updateValue(max_id!, forKey: "max_id")
            ApplicationViewController.loadTweet(path, params: params, { (data) in
                for tweet in data {
                    self.tweets.append(tweet)
                }
                self.timeLineUITableView.reloadData()
            }, { (error) in
                print(error.localizedDescription)
            })
        }
    }
//    private var lastContentOffset : CGFloat = 0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tabBarController?.selectedIndex == 1 {
            self.tep = 1
            if self.lastContentOffset > scrollView.contentOffset.y || scrollView.contentOffset.y < 0 {
                self.navigationController?.navigationBar.isHidden = true
                self.tep = 230
            } else if self.lastContentOffset < scrollView.contentOffset.y && scrollView.contentOffset.y > 0 {
                self.navigationController?.navigationBar.isHidden = false
//                self.tep = 0
            }
            self.lastContentOffset = scrollView.contentOffset.y
        }
        self.timeLineUITableView.reloadData()
    }
//    private var lastContentOffset : CGFloat = 0
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        var y = scrollView.contentOffset.y
//        print(y)
//        //        self.timeLineUITableView.reloadSections([0], with: UITableViewRowAnimation.automatic)
//        if y <= 0 {
//            print("a")
//            self.navigationController?.navigationBar.isHidden = false
//            self.tep = 0
//        } else if (y > scrollView.contentSize.height - scrollView.frame.size.height) {
//            print("b")
//            
//            self.navigationController?.navigationBar.isHidden = true
//            self.tep = 230
////            self.timeLineUITableView.reloadSections([0], with: UITableViewRowAnimation.none)
//        }
//        self.timeLineUITableView.reloadData()
//    }
    
    // we set a variable to hold the contentOffSet before scroll view scrolls
    var lastContentOffset: CGFloat = 0
    
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        self.lastContentOffset = scrollView.contentOffset.y
//    }
//    
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        
//        if (self.lastContentOffset < scrollView.contentOffset.y) {
//            self.tep = 230
//        } else if (self.lastContentOffset > scrollView.contentOffset.y) {
//            self.tep = 0
//        } else {
//            // didn't move
//        }
//        self.lastContentOffset = scrollView.contentOffset.y
//        self.timeLineUITableView.reloadData()
//        
//    }
}

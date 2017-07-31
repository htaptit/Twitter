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

class TimeLineTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate {
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
            
            ApplicationViewController.loadTweet(self.path!, { (tweet) in
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let curentTab = self.tabBarController?.tabBar.selectedItem?.title!
        return curentTab != "Timeline" && self.menu.data != nil ? 230 : 0
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
}

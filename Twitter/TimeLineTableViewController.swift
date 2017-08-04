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
    
    var defaultTopContraintTV: CGFloat = 0
    var defaultTopContraintBV: CGFloat = 50
    
    var previousScrollOffset: CGFloat = 0
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topConstraintTV: NSLayoutConstraint!
    @IBOutlet weak var topContraintBV: NSLayoutConstraint!
    
    // Mark : Information User
    @IBOutlet weak var accountNameUILabel: UILabel!
    @IBOutlet weak var accountNameTopUIView: UILabel!
    @IBOutlet weak var screenNameUILabel: UILabel!
    @IBOutlet weak var countTweetUILabel: UILabel!
    @IBOutlet weak var bacgroundPhotoUIImageView: UIImageView!
    @IBOutlet weak var avatarUIImageView: UIImageView!
    @IBOutlet weak var descriptionUILabel: UILabel!
    @IBOutlet weak var locationUILabel: UILabel!
    @IBOutlet weak var countFollowingUILabel: UILabel!
    @IBOutlet weak var countFollowerUILabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        
        self.timeLineUITableView.estimatedRowHeight = 300
        self.timeLineUITableView.rowHeight = UITableViewAutomaticDimension
        
        self.menu = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
        
        ApplicationViewController.userShow({ (data) in
            self.menu.data = data
            self.updateInforHeader(data)
        }) { (err) in
            print(err.localizedDescription)
        }
        
        
        if let title = self.tabBarController?.tabBar.selectedItem?.title {
            self.path = title != "Timeline" ? .user_timeline : .home_timeline
            
            if self.path == .home_timeline {
                NotificationCenter.default.addObserver(self, selector: #selector(openSideMenu(_:)), name: .open_menu, object: nil)
            } else {
                self.navigationController?.navigationBar.isHidden = true
                self.updateHeader()
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
        super.viewDidDisappear(animated)
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
    
    
    var since_id: String? = nil,
    max_id: String? = nil,
    isLoading: Bool = false
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !self.tweets.isEmpty {
            since_id = self.tweets[0].getTweetID
            let sid = Int(self.tweets[self.tweets.count - 1].getTweetID)! - 1
            max_id = String(sid)
        }
        let path: Path = self.tabBarController?.selectedIndex == 0 ? .home_timeline : .user_timeline
        var params: [String:String] = ["count": "200"]
        if scrollView.contentOffset.y <= 0 {
            if self.isLoading == false {
                self.isLoading = !self.isLoading
                params.updateValue(since_id!, forKey: "since_id")
                ApplicationViewController.loadTweet(path, params: params, { (data) in
                    print(data)
                    for tweet in data.reversed() {
                        self.tweets.insert(tweet, at: 0)
                    }
                    self.timeLineUITableView.reloadData()
                    self.isLoading = !self.isLoading
                }, { (err) in
                    print(err.localizedDescription)
                })
            }
        }
        
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height {
            if self.isLoading == false {
                self.isLoading = !self.isLoading
                params.updateValue(max_id!, forKey: "max_id")
                ApplicationViewController.loadTweet(path, params: params, { (data) in
                    for tweet in data {
                        self.tweets.append(tweet)
                    }
                    self.timeLineUITableView.reloadData()
                    self.isLoading = !self.isLoading
                }, { (error) in
                    print(error.localizedDescription)
                })
            }
        }
    }
}

extension TimeLineTableViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        if self.tabBarController?.selectedIndex == 1 {
            var newContraint1 = self.defaultTopContraintTV
            var newContraint2 = self.defaultTopContraintBV
            if isScrollingDown {
                if self.defaultTopContraintTV < 50 {
                    newContraint1 = self.defaultTopContraintTV + 1
                }
                
                if self.defaultTopContraintBV > -150 {
                    newContraint2 = self.defaultTopContraintBV - 10
                }
            } else if isScrollingUp == true && scrollView.contentOffset.y <= 30.0 {
                if self.defaultTopContraintTV > -20.0 {
                    newContraint1 = self.defaultTopContraintTV - 5
                }
                if self.defaultTopContraintBV < 50 {
                    newContraint2 = self.defaultTopContraintBV + 10
                }
            }
            
            if newContraint1 != self.defaultTopContraintTV {
                self.defaultTopContraintTV = newContraint1
                self.updateHeader()
            }
            
            if newContraint2 != self.defaultTopContraintBV {
                self.defaultTopContraintBV = newContraint2
                self.updateHeader()
            }
        }
    }
    func updateHeader() {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.6, animations: {
            self.topConstraintTV.constant = self.defaultTopContraintTV - 70.0
            self.topContraintBV.constant = self.defaultTopContraintBV - 70.0
            self.view.layoutIfNeeded()
        })
    }
    
    func updateInforHeader(_ data: TwitterData!) {
        if self.tabBarController?.selectedIndex != 0 {
            self.accountNameUILabel.text = data.name
            self.accountNameTopUIView.text = data.name
            self.screenNameUILabel.text = "@\(data.scname)"
            self.descriptionUILabel.text = data.description
            self.locationUILabel.text = data.location
            self.countFollowingUILabel.text = data.followers_count
            self.countFollowingUILabel.text = data.friends_count
            self.countTweetUILabel.text = "\(data.statuses_count) tweets"
            self.avatarUIImageView.asCircle()
            self.avatarUIImageView.sd_setImage(with: URL(string: data.avt), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
            self.bacgroundPhotoUIImageView.sd_setImage(with: URL(string: data.backgroundImage), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
//            self.topView.backgroundColor = UIColor(patternImage: UIImage(
            let url = URL(string: data.backgroundImage)
            let temp = try! Data(contentsOf: url!)
            let image = UIImage(data: temp)
            self.topView.backgroundColor = UIColor(patternImage: image!)
        }
    }
    
}

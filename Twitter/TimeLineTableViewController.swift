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
//    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var heightTopView: NSLayoutConstraint!
//    let maxHeaderHeight: CGFloat = 250
//    let minHeaderHeight: CGFloat = 50
    
    var defaultTopContraintTV: CGFloat = 0
    var defaultTopContraintBV: CGFloat = 50
    
    var previousScrollOffset: CGFloat = 0
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topConstraintTV: NSLayoutConstraint!
    @IBOutlet weak var topContraintBV: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
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
//                self.headerHeightConstraint.constant = self.maxHeaderHeight
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
    
}

extension TimeLineTableViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        if self.tabBarController?.selectedIndex == 1 {
            // Calculate new header height
            var newContraint1 = self.defaultTopContraintTV
            var newContraint2 = self.defaultTopContraintBV
            if isScrollingDown {
//                print("a")
                if self.defaultTopContraintTV != 50 {
                    newContraint1 = self.defaultTopContraintTV + 1
                }
                
                if self.defaultTopContraintBV != -150 {
                    newContraint2 = self.defaultTopContraintBV - 10
                }
            } else if isScrollingUp == true && scrollView.contentOffset.y <= 30.0 {
                if self.defaultTopContraintTV > -20.0 {
                    newContraint1 = self.defaultTopContraintTV - 5
                }
                
                if self.defaultTopContraintBV < 35 {
                    newContraint2 = self.defaultTopContraintBV + 10
                }
//                newContraint2 = self.defaultTopContraintBV - 50
            }
//            print(newContraint)
            // Header needs to animate
//            self.defaultTopcontraint = newContraint
//            print(self.defaultTopcontraint)
//            self.updateHeader()
            if newContraint1 != self.defaultTopContraintTV {
                self.defaultTopContraintTV = newContraint1
                self.updateHeader()
//                self.setScrollPosition(self.previousScrollOffset)
            }
            
            if newContraint2 != self.defaultTopContraintBV {
                self.defaultTopContraintBV = newContraint2
                self.updateHeader()
                //                self.setScrollPosition(self.previousScrollOffset)
            }
            
//            self.previousScrollOffset = scrollView.contentOffset.y
        }
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        self.scrollViewDidStopScrolling()
//    }
//    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if !decelerate {
//            self.scrollViewDidStopScrolling()
//        }
//    }
//    
//    func scrollViewDidStopScrolling() {
//        let range = self.maxHeaderHeight - self.minHeaderHeight
//        let midPoint = self.minHeaderHeight + (range / 2)
//        
//        if self.headerHeightConstraint.constant > midPoint {
//            self.expandHeader()
//        } else {
//            self.collapseHeader()
//        }
//    }
    
//    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
//        return true
//    }
    
//    func collapseHeader() {
//        self.view.layoutIfNeeded()
//        UIView.animate(withDuration: 0.2, animations: {
//            self.headerHeightConstraint.constant = self.minHeaderHeight
//            self.updateHeader()
//            self.view.layoutIfNeeded()
//        })
//    }
//    
//    func expandHeader() {
//        self.view.layoutIfNeeded()
//        UIView.animate(withDuration: 0.2, animations: {
//            self.headerHeightConstraint.constant = self.maxHeaderHeight
//            self.updateHeader()
//            self.view.layoutIfNeeded()
//        })
//    }
    
//    func setScrollPosition(_ position: CGFloat) {
//        self.timeLineUITableView.contentOffset = CGPoint(x: self.timeLineUITableView.contentOffset.x, y: position)
//    }
    
    func updateHeader() {
        
//        print(self.defaultTopcontraint)
//        let range = self.maxHeaderHeight - self.minHeaderHeight
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
//        let openAmount = self.headerHeightConstraint.constant - self.maxHeaderHeight
//        let percentage = openAmount / range
        // open amount ngay cang giam
            print(self.defaultTopContraintTV)
            self.topConstraintTV.constant = self.defaultTopContraintTV - 50 // cai nay phai dan tro ve 0
            self.topContraintBV.constant = self.defaultTopContraintBV - 50
            print(self.topContraintBV.constant)
            //        self.testView.alpha = percentage
            self.view.layoutIfNeeded()
        })
    }

}

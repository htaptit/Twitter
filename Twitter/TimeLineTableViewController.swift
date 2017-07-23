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
        
//        NotificationCenter.default.addObserver(self, selector: #selector(retweetOrQuote(_:)), name: .refresh, object: nil)
        
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
        if let buttonID = notification.object as? String {
            let arr = buttonID.splitStringToArray(separator: "_")
            let tweetID = String(describing: arr[1])
            let at = Int(String(describing: arr[2]))
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            switch self.tweets[at!].isRetweeted {
            case true:
                actionSheet.addAction(UIAlertAction(title: "Un-retweet", style: .default, handler: { (action) in
                    self.un_retweet(tweetID, at!)
                }))
            case false:
                actionSheet.addAction(UIAlertAction(title: "Retweet", style: .default, handler: { (action) in
                    self.retweet(tweetID, at!)
                }))
                
                actionSheet.addAction(UIAlertAction(title: "Quote tweet", style: .default, handler: { (action) in
                    
                }))
            }
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(actionSheet, animated: true, completion: nil)
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

extension UITableViewController {

    func formartCellTwitter(_ tweets: [TwitterData],_ index: IndexPath) -> TimelineTableViewCell {
        let tweet = tweets[index.row]
        var cell : TimelineTableViewCell?
        
        if tweet.isQuote {
            cell = tableView.dequeueReusableCell(withIdentifier: "QuoteTableViewCell", for: index) as? QuoteTableViewCell
            
            cell?.accountNameLabel.text = tweet.getAccountName
            cell?.screenNameLabel.text = "@\(tweet.getScreenName)"
            cell?.avatarImage.contentMode = .scaleAspectFit
            cell?.avatarImage.sd_setImage(with: URL(string: tweet.getAvatar()), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
            cell?.tweetTextLabel.text = tweet.getText
            
            // Quote Status
            cell?.qAccountNameLabel.text = tweet.q_account_name
            cell?.qScreenNameLabel.text = "@\(tweet.q_screen_name!)"
            cell?.qText.text = tweet.q_text
            
            
            cell?.qImageUIImageView.isHidden = true
            cell?.qImageHeightLayoutConstraint.constant = 0
            if let image = tweet.q_imageOnTweet {
                cell?.qImageUIImageView.isHidden = false
                cell?.qImageHeightLayoutConstraint.constant = 105
                cell?.qImageUIImageView.roundCorners([.bottomLeft, .bottomRight], radius: 5)
                cell?.qImageUIImageView.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
            }
            // End quoted status
            
            // set border color and width : tweet quoted
            cell?.tweetQuotedUIView.layer.borderWidth = 0.3
            cell?.tweetQuotedUIView.layer.borderColor = UIColor.darkGray.cgColor
            cell?.tweetQuotedUIView.layer.cornerRadius = 5
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: index) as? TweetTableViewCell
            cell?.imageHeightLayoutConstraint.constant = 0
            cell?.photoImage.isHidden = true
            if let image = tweet.imageOnTweet {
                cell?.imageHeightLayoutConstraint.constant = 150
                cell?.photoImage.isHidden = false
                cell?.photoImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
            }
            cell?.heightTypeTweet.constant = 0
            cell?.typeTweet.isHidden = true
            if tweet.isRetweeted {
                cell?.heightTypeTweet.constant = 8
                cell?.typeTweet.isHidden = false
                cell?.typeTweet.addImageToLabel()
                if let infoUser = tweet.infoUserOnRetweetedStatus {
                    let profileImage = infoUser["profile_image_url_https"] as? String
                    cell?.avatarImage.sd_setImage(with: URL(string: profileImage!), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
                    cell?.accountNameLabel.text = infoUser["name"]! as? String
                    cell?.screenNameLabel.text = "@\(infoUser["screen_name"]! as! String)"
                }
                cell?.avatarImage.contentMode = .scaleAspectFit
            } else {
                cell?.accountNameLabel.text = tweet.getAccountName
                cell?.screenNameLabel.text = "@\(tweet.getScreenName)"
                cell?.avatarImage.contentMode = .scaleAspectFit
                cell?.avatarImage.sd_setImage(with: URL(string: tweet.getAvatar()), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
            }
        }
        cell?.avatarImage.asCircle()
        cell?.tweetTextLabel.text = tweet.getText
        cell?.datetimeLabel.text = tweet.getCreatedAt
        
        
        let button_id = tweet.getTweetID + "_" + String(index.row)
        cell?.retweetButton.setTitle(button_id, for: UIControlState.normal)
        cell?.retweetCountLabel.text = tweet.retweetCount != 0 ? String(tweet.retweetCount) : ""
        cell?.likeCoutLabel.text = tweet.favoriteCount != 0 ? String(tweet.favoriteCount) : ""
        return cell!

    }
}

extension String {
    func splitStringToArray(separator: String) -> Array<Any> {
        let arr = self.components(separatedBy: separator)
        return arr
    }
}

extension UIImageView {
    func asCircle() {
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension UILabel {
    func addImageToLabel() {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: "retweet")
        attachment.bounds = CGRect(x: -1, y: -2, width: 15, height: 10)
        
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
        string.insert(attachmentString, at: 0)
        self.attributedText = string
    }
}

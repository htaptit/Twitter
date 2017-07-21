//
//  TimelineControllerViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/5/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import TwitterKit
import TwitterCore
import SDWebImage
class TimelineControllerViewController: UIViewController {
    // MARK : variable
    @IBOutlet var timelineTableView: UITableView!
    var listTweets = [TwitterData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        timelineTableView.delegate = self
        timelineTableView.translatesAutoresizingMaskIntoConstraints = false
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.frame.size.height = 40
        self.tabBarController?.tabBar.frame.origin.y = self.view.frame.size.height - 40
        
        self.timelineTableView.estimatedRowHeight = 400
        self.timelineTableView.rowHeight = UITableViewAutomaticDimension
        
        self.timelineTableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: "TweetTableViewCell")
        self.timelineTableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil) , forCellReuseIdentifier: "QuoteTableViewCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(retweetOrQuote), name: .refresh, object: nil)
        
        self.loadTweet()
        
    }
    
    func loadTweet() {
        if userIsLoggin() {
//          var params = ["screen_name": "htaptit", "count": "200"]
            let url_ = TwitterAPI.TwitterUrl(method: .GET, path: .home_timeline, twitterUrl: TwitterURL.api , parameters: ["screen_name": "htaptit", "count": "50"])
            TwitterAPI.getHomeTimeline(user: nil, url: url_ ,tweets: { (twitterData) in
                if !twitterData.isEmpty {
                    for item in twitterData {
                        self.listTweets.append(item)
                        self.timelineTableView.reloadData()
                    }
                }
            }) { (error) in
                print(error)
            }
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! TwitterHomeController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.newTweet != nil {
            listTweets.insert(appDelegate.newTweet!, at: 0)
            timelineTableView.reloadData()
            appDelegate.newTweet = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userIsLoggin() -> Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }
    
    
    @IBAction func Logout(_ sender: Any) {
        self.listTweets.removeAll()
        self.timelineTableView.reloadData()
        let userId = Twitter.sharedInstance().sessionStore.session()?.userID
        Twitter.sharedInstance().sessionStore.logOutUserID(userId!)
        let loginView = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as? TwitterHomeController
        self.navigationController?.pushViewController(loginView!, animated: true)
    }
    
    
    func retweetOrQuote(_ notification: Notification) {
        if let button_id = notification.object as? String {
            let arr = button_id.splitStringToArray(separator: "_")
            let tweet_id = String(describing: arr[0])
            let index = Int(arr[1] as! String)
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if self.listTweets[index!].isRetweeted {
                alert.addAction(UIAlertAction(title: "Un-retweet", style: .default, handler: { (action) in
                    self.un_retweet(tweet_id: tweet_id, row: index!)
                }))
            } else {
                alert.addAction(UIAlertAction(title: "Retweet", style: .default, handler: { (action) in
                    self.retweet(tweet_id: tweet_id, row: index!)
                }))
                
                alert.addAction(UIAlertAction(title: "Quote tweet", style: .default , handler: { (action) in
                    let quoteViewController = self.storyboard?.instantiateViewController(withIdentifier: "quoteView") as? QuoteViewController
                    quoteViewController?.tweet = self.listTweets[index!]
                    self.navigationController?.pushViewController(quoteViewController!, animated: true)
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel , handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            print("Tweet id not found ! ")
        }
        
    }
    
    func retweet(tweet_id: String, row: Int) {
        let url = TwitterAPI.TwitterUrl(method: .POST , path: .retweet_by_id , twitterUrl: .api, parameters: ["id": tweet_id])
        TwitterAPI.postNewTweet(user: nil, url: url, result: { (data) in
            let userIDRetweeted = data.getUserID
            let currentUserID = Twitter.sharedInstance().sessionStore.session()?.userID
            if "\(userIDRetweeted)" == currentUserID && userIDRetweeted == data.userID_retweet {
                self.listTweets.remove(at: row)
                self.listTweets.insert(data, at: 0)
            } else {
                self.listTweets[row].retweetCount = data.retweetCount
            }
        
//            let image = UIImage(named: "retweeted")
//            button.setImage(image, for: UIControlState.normal)
            self.timelineTableView.reloadData()
        }) { (error) in
            print(error)
        }
    }
    
    func un_retweet(tweet_id: String, row: Int) {
        let url = TwitterAPI.TwitterUrl(method: .POST , path: .unretweet_by_id , twitterUrl: .api, parameters: ["id": tweet_id])        
        TwitterAPI.postNewTweet(user: nil, url: url, result: { (data) in
            self.listTweets.remove(at: row)
            self.timelineTableView.reloadData()
        }) { (error) in
            print(error)
        }
    }
    
}

//extension String {
//    func splitStringToArray(separator: String) -> Array<Any> {
//        let arr = self.components(separatedBy: separator)
//        return arr
//    }
//}
//
//extension UIImageView {
//    func asCircle() {
//        self.layer.cornerRadius = self.frame.width / 2
//        self.layer.masksToBounds = true
//    }
//}
extension UILabel {
    func addImage() {
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: "retweet")
        attachment.bounds = CGRect(x: -1, y: -2, width: 15, height: 10)
        
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
        myString.insert(attachmentString, at: 0)
        self.attributedText = myString
        
    }
}


extension TimelineControllerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweet = self.listTweets[indexPath.row]
        var cell : TimelineTableViewCell?
        
        if tweet.isQuote {
            cell = tableView.dequeueReusableCell(withIdentifier: "QuoteTableViewCell", for: indexPath) as? QuoteTableViewCell
            
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
            cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: indexPath) as? TweetTableViewCell
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
                cell?.typeTweet.addImage()
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

        
        let button_id = tweet.getTweetID + "_" + String(indexPath.row)
        cell?.retweetButton.setTitle(button_id, for: UIControlState.normal)
        cell?.retweetCountLabel.text = tweet.retweetCount != 0 ? String(tweet.retweetCount) : ""
        cell?.likeCoutLabel.text = tweet.favoriteCount != 0 ? String(tweet.favoriteCount) : ""
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTweets.count
    }
    
}

//https://stackoverflow.com/questions/25630315/autolayout-unable-to-simultaneously-satisfy-constraints
//extension NSLayoutConstraint {
//    override open var description: String {
//        let id = identifier ?? ""
//        return "id: \(id), constant: \(constant)" //you may print whatever you want here
//    }
//}

//extension UIImageView {
//    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
//        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer.mask = mask
//    }
//}

extension TimelineControllerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweetDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "") as? TweetDetailViewController
        tweetDetailVC?.tweet = self.listTweets[indexPath.row]
        self.navigationController?.pushViewController(tweetDetailVC!, animated: true)
    }
}

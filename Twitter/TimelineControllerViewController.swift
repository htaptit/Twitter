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

class TimelineControllerViewController: UIViewController {
    // MARK : variable
    @IBOutlet var timelineTableView: UITableView!
    var listTweets = [TwitterData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        timelineTableView.delegate = self
        timelineTableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.timelineTableView.estimatedRowHeight = 400
        self.timelineTableView.rowHeight = UITableViewAutomaticDimension
        
        
        self.loadTweet()
        
    }
    
    func loadTweet() {
        if userIsLoggin() {
//          var params = ["screen_name": "htaptit", "count": "200"]
            let url_ = TwitterAPI.TwitterUrl(method: .GET, path: .home_timeline, twitterUrl: TwitterURL.api , parameters: ["screen_name": "htaptit", "count": "200"])
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
    
    
    @IBAction func retweetOrQuote(_ sender: UIButton) {
        if let button_id = sender.currentTitle {
            let arr = button_id.splitStringToArray(separator: "_")
            let tweet_id = String(describing: arr[0])
            let index = Int(arr[1] as! String)
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            if self.listTweets[index!].isRetweeted {
                alert.addAction(UIAlertAction(title: "Un-retweet", style: .default, handler: { (action) in
                    self.un_retweet(tweet_id: tweet_id, index: index!)
                }))
            } else {
                alert.addAction(UIAlertAction(title: "Retweet", style: .default, handler: { (action) in
                    self.retweet(button_id: button_id, button: sender)
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
    
    func retweet(button_id: String, button: UIButton) {
        let arr = button_id.splitStringToArray(separator: "_")
        let tweet_id = String(describing: arr[0])
        let index = Int(arr[1] as! String)

        let url = TwitterAPI.TwitterUrl(method: .POST , path: .retweet_by_id , twitterUrl: .api, parameters: ["id": tweet_id])
        TwitterAPI.postNewTweet(user: nil, url: url, result: { (data) in
            let userIDRetweeted = data.getUserID
            let currentUserID = Twitter.sharedInstance().sessionStore.session()?.userID
            if "\(userIDRetweeted)" == currentUserID && userIDRetweeted == data.userID_retweet {
                self.listTweets.remove(at: index!)
                self.listTweets.insert(data, at: 0)
            } else {
                self.listTweets[index!].retweetCount = data.retweetCount
            }
        
//            let image = UIImage(named: "retweeted")
//            button.setImage(image, for: UIControlState.normal)
            self.timelineTableView.reloadData()
        }) { (error) in
            print(error)
        }
    }
    
    func un_retweet(tweet_id: String, index: Int) {
        let url = TwitterAPI.TwitterUrl(method: .POST , path: .unretweet_by_id , twitterUrl: .api, parameters: ["id": tweet_id])        
        TwitterAPI.postNewTweet(user: nil, url: url, result: { (data) in
            self.listTweets.remove(at: index)
            self.timelineTableView.reloadData()
        }) { (error) in
            print(error)
        }
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
}
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
            cell = tableView.dequeueReusableCell(withIdentifier: "quote_tweet", for: indexPath) as? TimelineTableViewCell
            
            cell?.accountNameLabel.text = tweet.getAccountName
            cell?.screenNameLabel.text = "@\(tweet.getScreenName)"
            cell?.avatarImage.contentMode = .scaleAspectFit
            cell?.avatarImage.image = UIImage(data: tweet.getAvatar(nil)!)
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
                cell?.qImageUIImageView.image = UIImage(data: image)
            }
            // End quoted status
            
            // set border color and width : tweet quoted
            cell?.tweetQuotedUIView.layer.borderWidth = 0.3
            cell?.tweetQuotedUIView.layer.borderColor = UIColor.darkGray.cgColor
            cell?.tweetQuotedUIView.layer.cornerRadius = 5
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "tweet", for: indexPath) as? TimelineTableViewCell
            cell?.imageHeightLayoutConstraint.constant = 0
            cell?.photoImage.isHidden = true
            if let image = tweet.imageOnTweet {
                cell?.imageHeightLayoutConstraint.constant = 150
                cell?.photoImage.isHidden = false
                cell?.photoImage.image = UIImage(data: image)
            }
            cell?.heightTypeTweet.constant = 0
            cell?.typeTweetLabel.isHidden = true
            
            if tweet.isRetweeted {
                cell?.heightTypeTweet.constant = 8
                cell?.typeTweetLabel.isHidden = false
                cell?.typeTweetLabel.addImage()
                
                if let infoUser = tweet.infoUserOnRetweetedStatus {
                    cell?.avatarImage.image = UIImage(data: infoUser["avatar_data"]! as! Data)
                    cell?.accountNameLabel.text = infoUser["name"]! as? String
                    cell?.screenNameLabel.text = "@\(infoUser["screen_name"]! as! String)"
                }
                cell?.avatarImage.contentMode = .scaleAspectFit
            } else {
                cell?.accountNameLabel.text = tweet.getAccountName
                cell?.screenNameLabel.text = "@\(tweet.getScreenName)"
                cell?.avatarImage.contentMode = .scaleAspectFit
                cell?.avatarImage.image = UIImage(data: tweet.getAvatar(nil)!)
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

extension UIImageView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

extension TimelineControllerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweetDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "tweetDetail") as? TweetDetailViewController
        tweetDetailVC?.tweet = self.listTweets[indexPath.row]
        self.navigationController?.pushViewController(tweetDetailVC!, animated: true)
    }
}

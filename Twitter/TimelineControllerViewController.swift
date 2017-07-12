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
    var listTweets = [TwitterData]()
    @IBOutlet var timelineTableView: UITableView!
    var dataIsDoneGetting = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.timelineTableView.rowHeight = UITableViewAutomaticDimension
        self.timelineTableView.estimatedRowHeight = 100
        let url = TwitterApi.TwitterUrl(twitterURL: .api, path: .user_timeline, parameters: ["screen_name": "htaptit"])
        TwitterApi.ApiRequest(url: url) { (twitterResult) in
            switch twitterResult {
            case let .success(twitterData):
                for item in twitterData {
                    self.listTweets.append(item)
                    self.timelineTableView.reloadData()
                }
            case let .failure(error):
                print(error)
            }
            
        }

        if userIsLoggin() {
            
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! TwitterHomeController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userIsLoggin() -> Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }
    
    
    @IBAction func Logout(_ sender: Any) {
        let userId = Twitter.sharedInstance().sessionStore.session()?.userID
        Twitter.sharedInstance().sessionStore.logOutUserID(userId!)
        let loginView = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as? TwitterHomeController
        self.navigationController?.pushViewController(loginView!, animated: true)
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
//        var labelLeft = SMIconLabel(frame: CGRectMake(10, 10, view.frame.size.width - 20, 20))
        
        let attachment:NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: "retweet")
        attachment.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
        attachment.
        
        let attachmentString:NSAttributedString = NSAttributedString(attachment: attachment)
        let myString: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
        myString.append(attachmentString)
        self.attributedText = myString
        
    }
}
extension TimelineControllerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweet", for: indexPath) as? TimelineTableViewCell
        
        let tweet = self.listTweets[indexPath.row]
        
        cell?.tweetTextLabel.text = tweet.getText
        cell?.datetimeLabel.text = tweet.getCreatedAt
        
        cell?.imageHeightLayoutConstraint.constant = 0
        cell?.photoImage.isHidden = true
        
        if let image = tweet.imageOnTweet {
            cell?.imageHeightLayoutConstraint.constant = 150
            cell?.photoImage.isHidden = false
            cell?.photoImage.image = UIImage(data: image)
        }
        cell?.typeTweetLabel.heightAnchor.constraint(equalToConstant: 0)
        cell?.typeTweetLabel.isHidden = true
        
        cell?.avatarImage.asCircle()
        
        if tweet.isRetweeted {
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
            cell?.screenNameLabel.text = tweet.getScreenName
            cell?.avatarImage.contentMode = .scaleAspectFit
            cell?.avatarImage.image = UIImage(data: tweet.getAvatar(nil)!)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTweets.count
    }
    
}


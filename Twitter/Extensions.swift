//
//  Extensions.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/24/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
extension Notification.Name {
    static let new_notification = Notification.Name("new_notification")
    static let retweet_or_quote = Notification.Name("retweet_or_quote")
    static let to_twitter = Notification.Name("to_twitter")
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
            
            
            cell?.photoImage.isHidden = true
            cell?.imageHeightLayoutConstraint.constant = 0
            if let image = tweet.q_imageOnTweet {
                cell?.photoImage.isHidden = false
                cell?.imageHeightLayoutConstraint.constant = 160
//                cell?.photoImage.roundCorners([.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 5)
                cell?.photoImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
            }
            // End quoted status
            
            // set border color and width : tweet quoted
            cell?.tweetQuotedUIView.layer.borderWidth = 0.3
            cell?.tweetQuotedUIView.layer.borderColor = UIColor.lightGray.cgColor
            cell?.tweetQuotedUIView.layer.cornerRadius = 3
            cell?.tweetQuotedUIView.layer.masksToBounds = true
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: index) as? TweetTableViewCell
            cell?.imageHeightLayoutConstraint.constant = 0
            cell?.photoImage.isHidden = true
            if let image = tweet.imageOnTweet {
                cell?.imageHeightLayoutConstraint.constant = 160
                cell?.photoImage.isHidden = false
                cell?.photoImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
                cell?.photoImage.layer.cornerRadius = 3
                cell?.photoImage.layer.masksToBounds = true
            }
            cell?.heightTypeTweet.constant = 0
            cell?.typeTweet.isHidden = true
            cell?.retweetButton.setImage(UIImage(named: "retweet"), for: UIControlState.normal)
            if tweet.isRetweeted {
                cell?.retweetButton.setImage(UIImage(named: "retweeted"), for: UIControlState.normal)
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
        
        cell?.retweetButton.setTitle(String(index.row), for: UIControlState.normal)
        cell?.retweetCountLabel.text = tweet.retweetCount != 0 ? String(tweet.retweetCount) : ""
        cell?.likeButton.setTitle(String(index.row), for: UIControlState.normal)
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

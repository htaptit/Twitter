//
//  Extensions.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/24/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import Unbox

extension Notification.Name {
    static let new_notification = Notification.Name("new_notification")
    static let retweet_or_quote = Notification.Name("retweet_or_quote")
    static let to_twitter = Notification.Name("to_twitter")
    static let open_menu = Notification.Name("open_menu")
    static let back_timeline = Notification.Name("back_timeline")
}
extension UITableViewDataSource {
    
    func formartCellTwitter(_ tweets: [Tweet],_ index: IndexPath,_ tabIndex: Int,_ tableView: UITableView) -> TimelineTableViewCell {
        let tweet = tweets[index.row]
        var cell : TimelineTableViewCell?
        
        tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil) , forCellReuseIdentifier: "TweetTableViewCell")
        tableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil), forCellReuseIdentifier: "QuoteTableViewCell")

        if tweet.is_quote_status {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "QuoteTableViewCell", for: index) as? QuoteTableViewCell
            
            cell?.accountNameLabel.text = tweet.user.name
            cell?.screenNameLabel.text = "@\(tweet.user.screen_name)"
            cell?.avatarImage.contentMode = .scaleAspectFill
            cell?.avatarImage.sd_setImage(with: tweet.user.profile_image_url_https, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: [.continueInBackground, .lowPriority])
            cell?.tweetTextLabel.text = tweet.text
            
            // Quote Status
            cell?.imageHeightLayoutConstraint.constant = 0
            cell?.photoImage.isHidden = true
            if !tweet.retweeted {
                cell?.qAccountNameLabel.text = tweet.quoted_status?.user.name
                cell?.qScreenNameLabel.text = "@\(tweet.quoted_status?.user.screen_name ?? "")"
                cell?.qText.text = tweet.quoted_status?.text
                if let image_url = tweet.quoted_status?.image_url {
                    cell?.photoImage.isHidden = false
                    cell?.imageHeightLayoutConstraint.constant = 160
                    cell?.photoImage.contentMode = .scaleAspectFill
                    cell?.photoImage.sd_setImage(with: image_url, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: [.continueInBackground, .lowPriority])
                }
            } else {
                if let fr_count = tweet.retweeted_status?.favorite_count {
                    cell?.likeCoutLabel.text = "\(fr_count)"
                }
//                cell?.imageHeightLayoutConstraint.constant = 0
                cell?.tweetTextLabel.text = tweet.retweeted_status?.text
                cell?.accountNameLabel.text = tweet.retweeted_status?.user.name
                cell?.screenNameLabel.text = "@\(tweet.retweeted_status?.user.screen_name ?? "")"
                cell?.avatarImage.sd_setImage(with: tweet.retweeted_status?.user.profile_image_url_https, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: [.continueInBackground, .lowPriority])
                cell?.qText.text = tweet.retweeted_status?.quoted_status?.text
                cell?.qAccountNameLabel.text = tweet.retweeted_status?.quoted_status?.user.name
                cell?.qScreenNameLabel.text = "@\(tweet.retweeted_status?.quoted_status?.user.screen_name ?? "")"
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
            if let imageURL = tweet.imageURL {
                cell?.imageHeightLayoutConstraint.constant = 160
                cell?.photoImage.isHidden = false
                cell?.photoImage.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: [.continueInBackground, .lowPriority])
                cell?.photoImage.contentMode = .scaleAspectFill
                cell?.photoImage.layer.cornerRadius = 3
                cell?.photoImage.layer.masksToBounds = true
            }
            cell?.heightTypeTweet.constant = 0
            cell?.typeTweet.isHidden = true
            cell?.topIconUIButton.isHidden = true
            cell?.retweetButton.setImage(UIImage(named: "retweet"), for: UIControlState.normal)
            cell?.likeButton.setImage(UIImage(named: "like"), for: UIControlState.normal)
            if tweet.retweeted_status != nil {
                cell?.heightTypeTweet.constant = 8
//                cell?.typeTweet.addImageToLabel(name: "retweet")
                cell?.tweetTextLabel.text = tweet.retweeted_status?.text
                if let r_user = tweet.retweeted_status?.user {
                    let profile_image_url = r_user.profile_image_url_https
                    cell?.avatarImage.contentMode = .scaleAspectFill
                    cell?.avatarImage.sd_setImage(with: profile_image_url, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: [.continueInBackground, .lowPriority])
                    cell?.accountNameLabel.text = r_user.name
                    cell?.screenNameLabel.text = r_user.screen_name

                    if !tweet.retweeted {
                        cell?.typeTweet.isHidden = false
                        cell?.topIconUIButton.isHidden = false
                        cell?.typeTweet.text = "\(tweet.user.name) Retweeted"
                    }
                }
                cell?.avatarImage.contentMode = .scaleAspectFit
            } else {
                cell?.accountNameLabel.text = tweet.user.name
                cell?.screenNameLabel.text = "@\(tweet.user.screen_name)"
                cell?.avatarImage.contentMode = .scaleAspectFit
                cell?.avatarImage.sd_setImage(with: tweet.user.profile_image_url_https , placeholderImage: #imageLiteral(resourceName: "placeholder"), options: [.continueInBackground, .lowPriority])
                cell?.tweetTextLabel.text = tweet.text
            }
            
            if tweet.retweeted {
                cell?.typeTweet.isHidden = false
                cell?.topIconUIButton.isHidden = false
                cell?.retweetButton.setImage(UIImage(named: "retweeted"), for: UIControlState.normal)
                cell?.likeButton.setTitle(String(index.row), for: UIControlState.normal)
                if let favorite_count = tweet.retweeted_status?.favorite_count {
                    cell?.likeCoutLabel.text = "\(favorite_count)"
                }
            } else {
                cell?.likeButton.setTitle(String(index.row), for: UIControlState.normal)
                cell?.likeCoutLabel.text = tweet.farvorite_count != 0 ? "\(tweet.farvorite_count)" : ""
            }
            if tweet.favorited {
                cell?.likeButton.setImage(UIImage(named: "liked"), for: UIControlState.normal)
            }
        }
        cell?.avatarImage.asCircle()
//        cell?.likeCoutLabel.text =  "\(tweet.farvorite_count)"
        cell?.datetimeLabel.text = formarted_date(date: tweet.created_at, from: .twitter_date, to: .short)
        
        cell?.retweetButton.setTitle(String(index.row), for: UIControlState.normal)
        cell?.retweetCountLabel.text = tweet.retweet_count != 0 ? "\(tweet.retweet_count)" : ""
        
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
    func addImageToLabel(name: String) {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: name)
        attachment.bounds = CGRect(x: -1, y: -2, width: 15, height: 10)
        
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        let string: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
        string.insert(attachmentString, at: 0)
        self.attributedText = string
    }
}


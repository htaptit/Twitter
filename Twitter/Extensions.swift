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
        // init
       
        
        if tweet.is_quote_status {
            tableView.register(UINib(nibName: "QuoteTableViewCell", bundle: nil), forCellReuseIdentifier: "QuoteTableViewCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "QuoteTableViewCell", for: index) as? QuoteTableViewCell
            cell?.retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
            cell?.likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
            cell?.accountNameLabel.text = tweet.user.name
            cell?.screenNameLabel.text = "@\(tweet.user.screen_name)"
            cell?.avatarImage.contentMode = .scaleAspectFill
            cell?.avatarImage.sd_setImage(with: tweet.user.profile_image_url_https, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: [.continueInBackground, .lowPriority])
            cell?.tweetTextLabel.text = tweet.text
            cell?.imageHeightLayoutConstraint.constant = 0
            cell?.photoImage.isHidden = true
            // Quote Status
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
                cell?.likeCoutLabel.text = tweet.farvorite_count != 0 ? tweet.farvorite_count.numberTwFormart() : ""
                cell?.likeButton.setTitle(String(index.row), for: .normal)
                cell?.retweetCountLabel.text = tweet.retweet_count != 0 ?  tweet.retweet_count.numberTwFormart() : ""
                cell?.retweetButton.setTitle(String(index.row), for: .normal)
            } else {
                if tweet.retweeted_status != nil {
                    if let fr_count = tweet.retweeted_status?.favorite_count, let rt_count = tweet.retweeted_status?.retweet_count {
                        cell?.likeCoutLabel.text = fr_count != 0 ? fr_count.numberTwFormart() : ""
                        cell?.retweetCountLabel.text = rt_count != 0 ? rt_count.numberTwFormart() : ""
                    }
                    cell?.tweetTextLabel.text = tweet.retweeted_status?.text
                    cell?.accountNameLabel.text = tweet.retweeted_status?.user.name
                    cell?.screenNameLabel.text = "@\(tweet.retweeted_status?.user.screen_name ?? "")"
                    cell?.avatarImage.sd_setImage(with: tweet.retweeted_status?.user.profile_image_url_https, placeholderImage: #imageLiteral(resourceName: "placeholder"), options: [.continueInBackground, .lowPriority])
                    cell?.qText.text = tweet.retweeted_status?.quoted_status?.text
                    cell?.qAccountNameLabel.text = tweet.retweeted_status?.quoted_status?.user.name
                    cell?.qScreenNameLabel.text = "@\(tweet.retweeted_status?.quoted_status?.user.screen_name ?? "")"
                }
            }
            
            // End quoted status
            if tweet.retweeted {
                cell?.retweetButton.setImage(#imageLiteral(resourceName: "retweeted"), for: .normal)
            }
            
            if tweet.favorited {
                cell?.likeButton.setImage(#imageLiteral(resourceName: "liked"), for: .normal)
            }
            // set border color and width : tweet quoted
            cell?.tweetQuotedUIView.layer.borderWidth = 0.3
            cell?.tweetQuotedUIView.layer.borderColor = UIColor.lightGray.cgColor
            cell?.tweetQuotedUIView.layer.cornerRadius = 3
            cell?.tweetQuotedUIView.layer.masksToBounds = true
        } else {
            tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil) , forCellReuseIdentifier: "TweetTableViewCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "TweetTableViewCell", for: index) as? TweetTableViewCell
            cell?.heightTypeTweet.constant = 0
            cell?.typeTweet.isHidden = true
            cell?.topIconUIButton.isHidden = true
            cell?.retweetButton.setImage(#imageLiteral(resourceName: "retweet"), for: .normal)
            cell?.likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
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
            
            if tweet.retweeted_status != nil {
                cell?.heightTypeTweet.constant = 8
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
                cell?.retweetButton.setImage(#imageLiteral(resourceName: "retweeted"), for: .normal)
                cell?.likeButton.setTitle(String(index.row), for: .normal)
                if let favorite_count = tweet.retweeted_status?.favorite_count {
                    cell?.likeCoutLabel.text = favorite_count.numberTwFormart()
                }
            } else {
                cell?.likeButton.setTitle(String(index.row), for: .normal)
                cell?.likeCoutLabel.text = tweet.farvorite_count != 0 ? tweet.farvorite_count.numberTwFormart() : ""
            }
            if tweet.favorited {
                cell?.likeButton.setImage(#imageLiteral(resourceName: "liked"), for: .normal)
            }
        }
        cell?.avatarImage.asCircle()
        cell?.datetimeLabel.text = formarted_date(date: tweet.created_at, from: .twitter_date, to: .short)
        
        cell?.retweetButton.setTitle(String(index.row), for: .normal)
        cell?.retweetCountLabel.text = tweet.retweet_count != 0 ? tweet.retweet_count.numberTwFormart() : ""
        
        return cell!
        
    }
}

extension String {
    func splitStringToArray(separator: String) -> Array<Any> {
        let arr = self.components(separatedBy: separator)
        return arr
    }
}
extension Int {
    func numberTwFormart() -> String {
        let num = self % 1000
        if num > 0 && self >= 1000 {
            let c = String(format: "%.1f", Double(self / 1000).rounded(FloatingPointRoundingRule.up))
            return "\(c)K"
        } else {
            return "\(num)"
        }
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


//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/14/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit


class TweetDetailViewController: UIViewController {
    
    var tweet: TwitterData!
    
    @IBOutlet weak var topView: TweetView!
    @IBOutlet weak var heightTopViewNSLayoutContraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.viewTweet()
        print(tweet.tweet)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewTweet() {
//        self.topView.isHidden = true
//        if self.tabBarController?.selectedIndex == 0 {
        self.heightTopViewNSLayoutContraint.constant = 0.0
            self.topView.accountNameUILabel.text = self.tweet.getAccountName
            self.topView.screenNameUILabel.text = "@\(self.tweet.getScreenName)"
            self.topView.tweetUILabel.text = self.tweet.getText
            self.topView.datetimeUILabel.text = self.tweet.getCreatedAt
            self.topView.heightPhotoNSLayoutContraint.constant = 0.0
            if let imageURL = tweet.imageOnTweet {
                self.topView.heightPhotoNSLayoutContraint.constant = 150.0
                self.topView.photoUIImageView.sd_setImage(with: URL(string: imageURL) , placeholderImage: UIImage(named: "placeholder.png") , options: [.continueInBackground, .lowPriority])
                self.topView.photoUIImageView.contentMode = .scaleAspectFill
            }
            self.topView.heightTypeTweetNSLayoutContraint.constant = 0
            self.topView.typeTweetUILabel.isHidden = true
            self.topView.avatarUIImageView.sd_setImage(with: URL(string: self.tweet.getAvatar()), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
            self.topView.avatarUIImageView.asCircle()
            
            if self.tweet.isRetweeted {
                self.topView.retweetedUIButtom.setImage(UIImage(named: "retweeted"), for: UIControlState.normal)
            }
            
            if self.tweet.isFavorited {
                self.topView.likeUIbutton.setImage(UIImage(named: "liked"), for: .normal)
            }
//            self.topView.viewActivityUIView.addTopBorderWithColor(color: .black, width: 1)
//            self.topView.viewActivityUIView.addBottomBorderWithColor(color: .black, width: 1)
            self.topView.viewActivityUIView.isHidden = true
            self.topView.heightViewActivityNSLayoutContraint.constant = 0
            self.topView.countRetweetedUILabel.text = String(describing: self.tweet.retweetCount)
            self.topView.countLikeUILabel.text = String(describing: self.tweet.favoriteCount)
        
//            self.heightTopViewNSLayoutContraint.constant = self.topView.frame.height - (150.0 - self.topView.heightPhotoNSLayoutContraint.constant)
        }
//    }
}

extension UIView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

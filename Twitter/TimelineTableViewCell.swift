//
//  TimelineTableViewCell.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/6/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeTweetLabel: UILabel!
//    @IBOutlet weak var accoutNameLabel: UIView!

    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var typeTweet: UILabel!
    @IBOutlet weak var topIconUIButton: UIButton!
    @IBOutlet weak var heightTypeTweet: NSLayoutConstraint!
    @IBOutlet weak var imageHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var likeCoutLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!

    @IBOutlet weak var tweetQuotedUIView: UIView!
    @IBOutlet weak var qAccountNameLabel: UILabel!
    @IBOutlet weak var qScreenNameLabel: UILabel!
    @IBOutlet weak var qText: UILabel!
//    @IBOutlet weak var qImageUIImageView: UIImageView!
//    @IBOutlet weak var qImageHeightLayoutConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
//        photoImage.roundCorners([.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 8)
        // set border color and width : tweet quoted
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func reTweetAction(_ sender: UIButton) {
        if let row = sender.currentTitle {
            NotificationCenter.default.post(name: .to_twitter, object: ["row": row, "action": "RT"])
        }
    }
    
    @IBAction func Like(_ sender: UIButton) {
        if let row = sender.currentTitle {
            NotificationCenter.default.post(name: .to_twitter, object: ["row": row, "action": "Like"])
        }
    }
  
}



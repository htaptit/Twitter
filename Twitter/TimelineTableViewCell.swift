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
    @IBOutlet weak var qImageUIImageView: UIImageView!
    @IBOutlet weak var qImageHeightLayoutConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
//        photoImage.roundCorners([.bottomLeft, .bottomRight, .topLeft, .topRight], radius: 8)
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func reTweetAction(_ sender: UIButton) {
        if let buttonID = sender.currentTitle {
            let array = buttonID.splitStringToArray(separator: "_")
            print(array)
            NotificationCenter.default.post(name: .retweet_or_quote, object: ["tweet_id": array[0], "index": array[1]])
        }
    }
}



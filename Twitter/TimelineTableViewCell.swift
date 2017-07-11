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
    @IBOutlet weak var imageHeightLayoutConstraint: NSLayoutConstraint!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

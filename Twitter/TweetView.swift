//
//  StatusesView.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 8/7/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit

class TweetView: UIView {
    var view: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var typeTweetUILabel: UILabel!
    @IBOutlet weak var heightTypeTweetNSLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var avatarUIImageView: UIImageView!
    @IBOutlet weak var accountNameUILabel: UILabel!
    @IBOutlet weak var screenNameUILabel: UILabel!
    @IBOutlet weak var tweetUILabel: UILabel!
    @IBOutlet weak var photoUIImageView: UIImageView!
    @IBOutlet weak var heightPhotoNSLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var datetimeUILabel: UILabel!
    @IBOutlet weak var viewActivityUIView: UIView!
    @IBOutlet weak var viewInfoActivitiesUIView: UIView!
    @IBOutlet weak var countRetweetedUILabel: UILabel!
    @IBOutlet weak var countLikeUILabel: UILabel!
    @IBOutlet weak var heightViewActivityNSLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var heightCountViewInfoActivityNSLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var retweetedUIButtom: UIButton!
    @IBOutlet weak var likeUIbutton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    
    func loadViewFromNib() {
        Bundle.main.loadNibNamed("TweetView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

}

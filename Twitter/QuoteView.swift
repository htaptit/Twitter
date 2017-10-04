//
//  QuoteView.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 9/21/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit

class QuoteView: UIView {
    var view: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var avatarUIImageView: UIImageView!
    @IBOutlet weak var nameUILabel: UILabel!
    @IBOutlet weak var screenNameUILabel: UILabel!
    @IBOutlet weak var firstTextUILabel: UILabel!
    @IBOutlet weak var quoteNameUILabel: UILabel!
    @IBOutlet weak var quoteScreenNameUILabel: UILabel!
    @IBOutlet weak var quoteTextUILabel: UILabel!
    @IBOutlet weak var quotePhotoUIImageView: UIImageView!
    @IBOutlet weak var quoteTimeUILabel: UILabel!
    @IBOutlet weak var countRTweetUILabel: UIView!
    @IBOutlet weak var countLikeUILabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    func loadViewFromNib() {
        Bundle.main.loadNibNamed("QuoteView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}

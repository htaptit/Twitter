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

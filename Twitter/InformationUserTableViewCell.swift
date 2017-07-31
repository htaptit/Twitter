//
//  InformationUserTableViewCell.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/28/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit

class InformationUserTableViewCell: UITableViewCell {
    var inforUser: TwitterData!
    
    @IBOutlet weak var profileBackgroundUIImageView: UIImageView!
    @IBOutlet weak var avatartUIImageView: UIImageView!
    @IBOutlet weak var accountNameUILabel: UILabel!
    @IBOutlet weak var descriptionUILabel: UILabel!
    @IBOutlet weak var screenNameUILabel: UILabel!
    @IBOutlet weak var currentLocationUILabel: UILabel!
    @IBOutlet weak var countFlowingUILabel: UILabel!
    @IBOutlet weak var countFollwerUILabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func backToTimline(_ sender: UIButton) {
        print("aa")
        NotificationCenter.default.post(name: .back_timeline, object: nil)
    }
}

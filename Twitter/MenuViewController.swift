//
//  MenuViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/27/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var avataUIImage: UIImageView!
    @IBOutlet weak var NameUILabel: UILabel!
    @IBOutlet weak var screenNameUILabel: UILabel!
    @IBOutlet weak var countFlowingUILabel: UILabel!
    
    @IBOutlet weak var topUIView: UIView!
    @IBOutlet weak var flowingUILabel: UILabel! // friends_count
    @IBOutlet weak var countFolowers: UILabel!
    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var followersUILabel: UILabel! // followers_count
    @IBOutlet weak var rightUIView: UIView!
    
    @IBOutlet weak var bottomContrainNSLayout: NSLayoutConstraint!
    var data: TwitterData!
    var menu_top: [String] = ["Brief", "List", "Moment"]
    var menu_botton: [String] = ["Install and privacy", "Help", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menuTable.estimatedRowHeight = 300
        menuTable.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
        menuTable.tableFooterView = UIView()
        avataUIImage.sd_setImage(with: URL(string: data.avt), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
        avataUIImage.asCircle()
        NameUILabel.text = data.name
        screenNameUILabel.text = "@\(data.scname)"
        flowingUILabel.text = "Following"
        countFlowingUILabel.text = data.followers_count
        followersUILabel.text = "Followers"
        countFolowers.text = data.friends_count
        
    }
    @IBAction func moreMenu(_ sender: UIButton) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "menu_top", for: indexPath)
            cell.textLabel?.text = self.menu_top[indexPath.row]
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "menu_bottom", for: indexPath)
            cell.textLabel?.text = self.menu_botton[indexPath.row]
        default: break
        }
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

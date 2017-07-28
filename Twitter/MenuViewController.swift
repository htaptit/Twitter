//
//  MenuViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/27/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import TwitterKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var countTweet: UILabel!
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
    var menu_top: [String] = ["Profile", "Lists", "Moments"]
    var menu_botton: [String] = ["Setting and privacy", "Help Center", ""]
    var arrayNameImage: [String] = ["user", "list", "moment"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        menu()
    }
    
    private func menu() {
        menuTable.estimatedRowHeight = 300
        menuTable.rowHeight = UITableViewAutomaticDimension
        menuTable.tableFooterView = UIView()
        avataUIImage.sd_setImage(with: URL(string: data.avt), placeholderImage: UIImage(named: "placeholder.png"), options: [.continueInBackground, .lowPriority])
        avataUIImage.asCircle()
        NameUILabel.text = data.name
        screenNameUILabel.text = "@\(data.scname)"
        flowingUILabel.text = "Following"
        countFlowingUILabel.text = data.followers_count
        followersUILabel.text = "Followers"
        countFolowers.text = data.friends_count
        countTweet.text = data.statuses_count
    }
    
    @IBAction func logout(_ sender: UIButton) {
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            Twitter.sharedInstance().sessionStore.logOutUserID(userID)
        }
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! TwitterHomeController
        self.navigationController?.pushViewController(loginVC, animated: true)
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
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
        tableView.register(UINib(nibName: "SectionInMenu", bundle: nil) , forCellReuseIdentifier: "SectionInMenu")
        
        var cell: SectionInMenu!
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "SectionInMenu", for: indexPath) as! SectionInMenu
            cell.nameMenuUILabel.text = self.menu_top[indexPath.row]
            cell.icoMenuUIButton.setImage(UIImage(named: self.arrayNameImage[indexPath.row]) , for: .normal)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "SectionInMenu", for: indexPath) as! SectionInMenu
            cell.nameMenuUILabel.text = self.menu_botton[indexPath.row]
        default: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                NotificationCenter.default.post(name: .open_menu , object: nil)
                self.tabBarController?.selectedIndex = 1
            default:
                break
            }
        } else {
            
        }
    }
    
    @IBAction func openSideMenu(_ sender: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: .open_menu , object: nil)
    }

    @IBAction func gotoHomeUser(_ sender: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: .open_menu , object: nil)
        self.tabBarController?.selectedIndex = 1
    }
}

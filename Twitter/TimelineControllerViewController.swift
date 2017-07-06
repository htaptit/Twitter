//
//  TimelineControllerViewController.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/5/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import UIKit
import TwitterKit
import TwitterCore

class TimelineControllerViewController: UIViewController {
    var listTweets = [[String:Any]]()
    @IBOutlet var timelineTableView: UITableView!
    var dataIsDoneGetting = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        Twitter.sharedInstance().sessionStore.logOutUserID((Twitter.sharedInstance().sessionStore.session()?.userID)!)
        if userIsLoggin() {
            getUserTimeline()
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "home") as! TwitterHomeController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if listTweets.isEmpty && dataIsDoneGetting == true {
            getUserTimeline()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userIsLoggin() -> Bool {
        return Twitter.sharedInstance().sessionStore.session() != nil
    }
    
    func getUserTimeline() {
        let store = Twitter.sharedInstance().sessionStore
        
        let lastSession = store.session()!
        
        let client = TWTRAPIClient(userID: lastSession.userID)
        
        
        let url = client.urlRequest(withMethod: "GET", url: "https://api.twitter.com/1.1/statuses/user_timeline.json", parameters: nil, error: NSErrorPointer.none)
        client.sendTwitterRequest(url) { (response, data, error) in
            do {
                let response = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [[String : Any]]
                if response != nil {
                    for item in response! {
                        self.listTweets.append(item)
                    }
                    self.dataIsDoneGetting = true
                    self.timelineTableView.reloadData()
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension TimelineControllerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweet", for: indexPath) as? TimelineTableViewCell
        cell?.tweetLabel?.text = self.listTweets[indexPath.row]["text"] as? String
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTweets.count
    }
}


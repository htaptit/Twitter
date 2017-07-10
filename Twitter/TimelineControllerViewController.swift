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
        let url = TwitterApi.TwitterUrl(twitterURL: .api, path: .user_timeline,parameters: ["screen_name": "htaptit"])
        let response = TwitterApi.ApiRequest(url: url)
        
        
        
        self.timelineTableView.rowHeight = UITableViewAutomaticDimension
        self.timelineTableView.estimatedRowHeight = 200
        
        if userIsLoggin() {
            getUserTimeline()
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as! TwitterHomeController
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
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
    
    
    @IBAction func Logout(_ sender: Any) {
        let userId = Twitter.sharedInstance().sessionStore.session()?.userID
        Twitter.sharedInstance().sessionStore.logOutUserID(userId!)
        let loginView = self.storyboard?.instantiateViewController(withIdentifier: "loginView") as? TwitterHomeController
        self.navigationController?.pushViewController(loginView!, animated: true)
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
        let tweet = self.listTweets[indexPath.row]
        
        cell?.tweetTextLabel?.text = tweet["text"] as? String
        let isRetweeted : Bool = tweet["retweeted_status"] != nil
        if isRetweeted {
            if let retweet = tweet["retweeted_status"] as? [String: Any] {
                if let infoRT = retweet["user"] as? [String:Any] {
                    cell?.accountNameLabel.text = infoRT["name"] as? String
                    cell?.screenNameLabel.text = "@\(String(describing: infoRT["screen_name"]!))"
                    
                    let rootImageAvatart = (infoRT["profile_image_url_https"] as! String).replacingOccurrences(of: "_normal", with: "")
                    let urlAvatar = URL(string: rootImageAvatart)
                    let data = try? Data(contentsOf: urlAvatar!)
                    if let imageData = data {
                        cell?.avatarImage.contentMode = .scaleAspectFit
                        cell?.avatarImage.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            if let infoTW = tweet["user"] as? [String:Any] {
                cell?.accountNameLabel.text = infoTW["name"] as? String
                cell?.screenNameLabel.text = "@\(String(describing: infoTW["screen_name"]!))"
                
                let rootImageAvatart = (infoTW["profile_image_url_https"] as! String).replacingOccurrences(of: "_normal", with: "")
                let urlAvatar = URL(string: rootImageAvatart)
                let data = try? Data(contentsOf: urlAvatar!)
                if let imageData = data {
                    cell?.avatarImage.contentMode = .scaleAspectFit
                    cell?.avatarImage.image = UIImage(data: imageData)
                }
            }

        }
        
        if let entries =  tweet["entities"] as? [String:Any] {
            if entries["media"] != nil {
                cell?.imageHeightLayoutConstraint.constant = 200
                cell?.photoImage.isHidden = false
            } else {
                cell?.imageHeightLayoutConstraint.constant = 0
                cell?.photoImage.isHidden = true
            }
            
        }
        
        cell?.datetimeLabel.text = tweet["created_at"] as? String
        
        cell?.tweetTextLabel.numberOfLines = 0
        cell?.tweetTextLabel.lineBreakMode = .byWordWrapping
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTweets.count
    }
    
//    func convertDateFormatter(date: String) -> String?
//    {
//        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
//        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
//        let date = dateFormatter.date(from: date)
//        
//        
//        dateFormatter.dateFormat = "yyyy MMM EEEE HH:mm"///this is what you want to convert format
//        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone!
//        let timeStamp = dateFormatter.string(from: date!)
//        
//        
//        return timeStamp
//    }
}


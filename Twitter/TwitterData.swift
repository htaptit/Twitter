//
//  TwitterData.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/10/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import Foundation

class TwitterData {
    
    var tweet: [String:Any]
    var userOfTweet: [String:Any]? = nil
    var retweetedStatus: [String:Any]? = nil
    
    init(tweet: [String:Any]) {
        self.tweet = tweet
//        self.userOfTweet = tweet["user"] as! [String : Any]
        if let user = self.tweet["user"] as? [String : Any] {
            self.userOfTweet = user
        }
        if let retweeted = self.tweet["retweeted_status"] as? [String: Any] {
            self.retweetedStatus = retweeted
        }
    }
    
    public func asString(value: Any) -> String {
        return (value as? String)!
    }
    
    var getTweetID: String {
        get {
            return asString(value: self.tweet["id_str"]!)
        }
    }
    
    var getCreatedAt: String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "eee MMM dd HH:mm:ss ZZZZ yyyy"
        let date = dateFormat.date(from: self.tweet["created_at"] as! String)
        dateFormat.dateFormat = "yyyy/MM/dd HH:mm"
        let da = dateFormat.string(from: date!)
        return da
    }
    
    var getUserID: Int {
        get {
            return self.userOfTweet!["id"] as! Int
        }
    }
    
    var getAccountName: String {
        get {
            return asString(value: self.userOfTweet!["name"]!)
        }
    }
    
    var getScreenName: String {
        get {
            return asString(value: self.userOfTweet!["screen_name"]!)
        }
    }
    
    var getText: String {
        get {
            return asString(value: self.tweet["text"]!)
        }
    }
    
    
    var isRetweeted: Bool {
        get{
            return self.tweet["retweeted"] as! Bool
        }
        set(newValue) {
            self.tweet["retweeted"] = newValue
        }
        
    }
    
    var isExistRetweetedStatus: Bool {
        return self.tweet["retweeted_status"] != nil
    }
    
    var retweeted: [String:Any]? {
        guard let retweeted = self.tweet["retweeted_status"] as? [String: Any] else {
            return nil
        }
        
        return retweeted
        
    }
    
    var userID_retweet: Int? {
        guard let user = retweeted?["user"] as? [String: Any] else {
            return nil
        }
        let userID = user["id"] as? Int
        return userID
    }
    
    var retweetCount: Int {
        get {
            return self.tweet["retweet_count"] as! Int
        }
        set(newValue) {
           self.tweet["retweet_count"] = newValue
        }
    }
    
    var isFavorited: Bool {
        get {
            return self.tweet["favorited"] as! Bool
        }
        set(newValue) {
            self.tweet["favorited"] = newValue
        }
        
    }
    
    var favoriteCount: Int {
        get {
            if isExistRetweetedStatus {
                return self.retweetedStatus!["favorite_count"]! as! Int
            }
            return self.tweet["favorite_count"] as! Int
        }
        set(newValue) {
            if isExistRetweetedStatus {
                self.retweetedStatus!["favorite_count"] = newValue
            } else {
                self.tweet["favorite_count"] = newValue
            }
            
        }
    }
    
    var infoUserOnRetweetedStatus: [String: Any]? {
        if let retweeted_status = self.retweeted {
            let user = retweeted_status["user"] as! [String:Any]
            return user
        }
        return nil
    }
    
    
    var imageOnTweet : String? {
        guard let entities = self.tweet["entities"] as? [String:Any] else { return nil }
        
        if let media = entities["media"] as? Array<Any> {
            let inforMedia = media[0] as! [String:Any]
                return asString(value: inforMedia["media_url_https"]!)
        }
        
        return nil
    }
    
    var tweetUrl: String? {
        if let id = self.tweet["id_str"] {
            return "https://twitter.com/\(self.getScreenName)/status/\(id)"
        }
        return nil
    }
    
    var tweetUrlShort: String? {
        guard let entities = self.tweet["entities"] as? [String:Any] else { return nil }
        if let media = entities["media"] as? Array<Any> {
            let inforMedia = media[0] as! [String:Any]
            return asString(value: inforMedia["url"]!)
        }
        
        return nil
    }
    
    func getAvatar() -> String {
        let tempSaveUrl = asString(value: self.userOfTweet?["profile_image_url_https"]! as Any)
        let url = tempSaveUrl.replacingOccurrences(of: "_normal", with: "")
        return url
    }
    
    var isQuote: Bool {
        if let isQuote = self.tweet["is_quote_status"] {
            if isQuote as? Bool == true && self.isRetweeted == false {
                return true
            }
        }
        return false
    }
    
    var quoted_status: [String: Any]? {
        guard let quoted = self.tweet["quoted_status"] as? [String:Any] else {
            return nil
        }
        
        return quoted
    }
    
    var q_user: [String: Any]? {
        guard let user = self.quoted_status?["user"] else {
            return nil
        }
        
        return (user as! [String : Any])
    }
    
    var q_account_name: String? {
        if let name = self.q_user?["name"] {
            return asString(value: name)
        }
        return nil
    }
    
    var q_screen_name: String? {
        if let sname = self.q_user?["screen_name"] {
            return asString(value: sname)
        }
        return nil
    }
    
    var q_text: String? {
        if let text = self.quoted_status?["text"] {
            return asString(value: text)
        }
        return nil
    }
    var q_imageOnTweet : String? {
        guard let entities = self.quoted_status?["entities"] as? [String:Any] else { return nil }
        if let media = entities["media"] as? Array<Any> {
            let inforMedia = media[0] as! [String:Any]
            return asString(value: inforMedia["media_url_https"]!)
        }
        
        return nil
    }
    
    
    
    
    // User show
    
    var avt: String {
        let tempSaveUrl = asString(value: self.tweet["profile_image_url_https"]! as Any)
        let url = tempSaveUrl.replacingOccurrences(of: "_normal", with: "")
        return url
    }
    
    var name: String {
        return asString(value: self.tweet["name"]!)
    }
    
    var scname: String {
        return asString(value: self.tweet["screen_name"]!)
    }
    var followers_count: String {
        return String(self.tweet["followers_count"] as! Int)
    }
    
    var friends_count: String {
        return String(self.tweet["friends_count"]  as! Int)
    }
}

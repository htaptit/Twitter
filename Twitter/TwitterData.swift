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
    let userOfTweet: [String:Any]
    
    init(tweet: [String:Any]) {
        self.tweet = tweet
        self.userOfTweet = tweet["user"] as! [String : Any]
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
        return "2015/10/10"
    }
    
    var getAccountName: String {
        get {
            return asString(value: self.userOfTweet["name"]!)
        }
    }
    
    var getScreenName: String {
        get {
//            return ("@\(asString(value: self.userOfTweet["screen_name"]!))")
            return asString(value: self.userOfTweet["screen_name"]!)
        }
    }
    
    var getText: String {
        get {
            return asString(value: self.tweet["text"]!)
        }
    }
    
    
    var isRetweeted: Bool {
        return self.tweet["retweeted_status"] != nil
    }
    
    var retweeted: [String:Any]? {
        guard let retweeted = self.tweet["retweeted_status"] as? [String: Any] else {
            return nil
        }
        
        return retweeted
        
    }
    
    var retweetCount: Int {
        get {
            return self.tweet["retweet_count"] as! Int
        }
        set(newValue) {
           self.tweet["retweet_count"] = newValue
        }
    }
    
    var favoriteCount: Int {
        get {
            return self.tweet["favorite_count"] as! Int
        }
    }
    
    var infoUserOnRetweetedStatus: [String: Any]? {
        if let retweeted_status = self.retweeted {
            var user = retweeted_status["user"] as! [String:Any]
            
            let profile_image_url_https = asString(value: user["profile_image_url_https"]!)
            user["avatar_data"] = self.getAvatar(profile_image_url_https)
            return user
        }
        return nil
    }
    
    
    var imageOnTweet : Data? {
        guard let entities = self.tweet["entities"] as? [String:Any] else { return nil }
        
        if let media = entities["media"] as? Array<Any> {
            let inforMedia = media[0] as! [String:Any]
            let urlString = asString(value: inforMedia["media_url_https"]!)
            return self.getAvatar(urlString)
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
    
    func getAvatar(_ urlString : String?) -> Data? {
        let tempSaveUrl: String?
        
        if urlString != nil {
            tempSaveUrl = urlString!
        } else {
            tempSaveUrl = asString(value: self.userOfTweet["profile_image_url_https"]!)
        }
        
        guard let url = tempSaveUrl  else {
            return nil
        }
        
        let removeNormalStringURL = asString(value: url).replacingOccurrences(of: "_normal", with: "")
        let avatarData = try? Data(contentsOf: URL(string: removeNormalStringURL)!)
        if let avatarUrl = avatarData {
            return avatarUrl
        }
        
        return nil
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
    var q_imageOnTweet : Data? {
        guard let entities = self.quoted_status?["entities"] as? [String:Any] else { return nil }
        if let media = entities["media"] as? Array<Any> {
            let inforMedia = media[0] as! [String:Any]
            let urlString = asString(value: inforMedia["media_url_https"]!)
            return self.getAvatar(urlString)
        }
        
        return nil
    }
}

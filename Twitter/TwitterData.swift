//
//  TwitterData.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/10/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import Foundation

class TwitterData {
    
    let tweet: [String:Any]
    let userOfTweet: [String:Any]
    
    init(tweet: [String:Any], userOfTweet: [String:Any]) {
        self.tweet = tweet
        self.userOfTweet = userOfTweet
    }
    
    public func asString(value: Any) -> String {
        return (value as? String)!
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
            return ("@\(asString(value: self.userOfTweet["screen_name"]!))")
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
    
    
}

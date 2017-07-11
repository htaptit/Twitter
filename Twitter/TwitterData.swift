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
    
    var getCreatedAt: Date {
        return self.tweet["created_at"] as! Date
    }
    
    var getAccountName: String {
        get {
            return asString(value: self.tweet["name"]!)
        }
    }
    
    var getScreenName: String {
        get {
            return asString(value: self.userOfTweet["screen_name"]!)
        }
    }
    
    var getAvatar: Data? {
        get {
            guard let url = self.userOfTweet["profile_image_url_https"]  else {
                return nil
            }
            
            let removeNormalStringURL = asString(value: url).replacingOccurrences(of: "_normal", with: "")
            let avatarUrl = try? Data(contentsOf: URL(string: removeNormalStringURL)!)
            return avatarUrl
            
        }
    }
    
    var isRetweeted: Bool {
        return self.tweet["retweeted"] as! Bool
    }
    
    var retweeted: [String:Any]? {
        guard let retweeted = self.tweet["retweeted_status"] as? [String: Any] else {
            return nil
        }
        
        return retweeted
        
    }
}

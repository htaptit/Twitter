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
            let url = asString(value: self.userOfTweet["profile_image_url_https"]!).replacingOccurrences(of: "_nomal", with: "")
            let avUrl = try? Data(contentsOf: URL(string: url)!)
            return avUrl
        }
    }
}

//
//  Tweet.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 10/5/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import Foundation
import Unbox

struct Tweet {
//    let tweet: TwitterData
    
    let id : Int
    var created_at: String
    let text : String
    var retweeted: Bool
    var retweet_count: Int
    let retweeted_status : RQStatus?
    var is_quote_status: Bool
    let quoted_status: RQStatus?
    
    var favorited: Bool
    var farvorite_count: Int
    
    let imageURL : URL?
    let user: User
    
}

extension Tweet : Unboxable {
    init(unboxer: Unboxer) throws {
        
        self.id = try unboxer.unbox(key: "id")
        self.created_at = try unboxer.unbox(key: "created_at")
        self.text = try unboxer.unbox(key: "text")
        self.retweeted = try unboxer.unbox(key: "retweeted")
        self.retweet_count = try unboxer.unbox(key: "retweet_count")
        self.retweeted_status = try? unboxer.unbox(key: "retweeted_status")

        self.is_quote_status = try unboxer.unbox(key: "is_quote_status")
        self.quoted_status = try? unboxer.unbox(key: "quoted_status")
        self.favorited = try unboxer.unbox(key: "favorited")
        self.farvorite_count = try unboxer.unbox(key: "favorite_count")
        
        self.imageURL = try? unboxer.unbox(keyPath: "entities.media.0.media_url_https")

        self.user = try unboxer.unbox(key: "user")
        
    }

    
}


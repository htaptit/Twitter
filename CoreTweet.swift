//
//  RetweetedStatus.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 10/5/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import Foundation
import Unbox

struct CoreTweet {
    let id : Int
    let favorite_count: Int
    let text: String
    let image_url: URL?
    let user : User
    
}

extension CoreTweet : Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.text = try unboxer.unbox(key: "text")
        self.favorite_count = try unboxer.unbox(key: "favorite_count")
        self.image_url = try? unboxer.unbox(keyPath: "entities.media.0.media_url_https")
        self.user = try unboxer.unbox(key: "user")
    }
}


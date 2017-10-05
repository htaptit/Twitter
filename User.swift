//
//  InformationUserTweet.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 10/5/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import Foundation
import Unbox

struct User {
    let id : Int
    let name: String
    let screen_name: String
    let profile_image_url_https: URL
}

extension User : Unboxable {
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.screen_name = try unboxer.unbox(key: "screen_name")
        self.profile_image_url_https = try unboxer.unbox(key: "profile_image_url_https")
    }
}


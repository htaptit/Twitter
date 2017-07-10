//
//  TwitterData.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/10/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import Foundation

class TwitterData {
    let accountName: String
    let screenName: String
    let createdAt: Date
    let tweetText: String
    let avatarImage: URL?
    let photoImage: URL?
    init(accountName: String, screenName: String, createdAt: Date, tweetText: String, avatarImage: URL, photoImage: URL?) {
        self.accountName = accountName
        self.screenName = screenName
        self.createdAt = createdAt
        self.tweetText = tweetText
        self.avatarImage = avatarImage
        self.photoImage = photoImage
    }
}

//
//  TwitterStore.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/10/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import Foundation

class TwitterStore {
    
    func getUserTimeline() {
        let url = TwitterApi.TwitterUrl(twitterURL: .api, path: .user_timeline, parameters: ["screen_name": "htaptit"])
        TwitterApi.ApiRequest(url: url) { (twitterResult) in
            switch twitterResult {
            case let .success(twitterData):
                for item in twitterData {
                    print(item.getScreenName)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
}

//
//  TwitterApi.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/6/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import Foundation
import TwitterKit
import TwitterCore

enum Path: String {
    case user_timeline = "statuses/user_timeline.json"
}

public enum TwitterURL {
    case api
    var url: URL {
        switch self {
        case .api:
            return URL(string: "https://api.twitter.com/1.1/")!
        }
    }
    
}

enum TwitterResult {
    case success([TwitterData])
    case failure(Error)
}

enum TwitterError {
    case invailJSONData
}

struct TwitterApi {
    static var client : TWTRAPIClient = TWTRAPIClient(userID: nil)
    
    init() {
        let user_id = Twitter.sharedInstance().sessionStore.session()?.userID
        TwitterApi.client = TWTRAPIClient(userID: user_id!)
    }
    
    static func TwitterUrl(twitterURL: TwitterURL , path: Path, parameters: [String: String]?) -> URLRequest {
        
        var components = URLComponents(string: twitterURL.url.absoluteString + path.rawValue)
        var queryItem = [URLQueryItem]()
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItem.append(item)
            }
        }
        
        components?.queryItems = queryItem
        
        return URLRequest(url: components!.url!)
    }
    

    static func ApiRequest(url: URLRequest) {
        TwitterApi.client.sendTwitterRequest(url) { (response, data, error) in
            do {
                let result = try JSONSerialization.jsonObject(with: data!, options: [])
                
                var finalTweet = [TwitterData]()
                
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    static func Tweets(data: Data) {
        print(data)
    }
}

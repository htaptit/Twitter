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
    

    static func ApiRequest(url: URLRequest, completion: @escaping (TwitterResult) -> Void) {
        TwitterApi.client.sendTwitterRequest(url) { (response, data, error) in
            do {

                let result = Tweets(fromJSON: data)
                completion(result)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func Tweets(fromJSON data: Data?) -> TwitterResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data!, options: [])
            
            guard let jsonDictionary = jsonObject as? [[String: Any]] else {
                return .failure(TwitterError.invailJSONData as! Error)
            }
            
            var finalTweet = [TwitterData]()
            for photoJSON in jsonDictionary {
                if let tweet = Tweet(fromJSON: photoJSON) {
                    finalTweet.append(tweet)
                }
            }
            	
            if finalTweet.isEmpty {
                return .failure(TwitterError.invailJSONData as! Error)
            }
            
            return .success(finalTweet)
        } catch let error {
            return .failure(error)
        }
    }
    
    static func Tweet(fromJSON data: [String:Any]) -> TwitterData? {
        guard
            let userOfTweet = data["user"] as? [String:Any]
        else {
            return nil
        }
        
        
        return TwitterData(tweet: data, userOfTweet: userOfTweet)
    }
}

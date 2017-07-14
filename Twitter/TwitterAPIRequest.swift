//
//  TwitterAPIRequest.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 7/13/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import Foundation
import TwitterKit

public enum Path: String {
    case user_timeline = "statuses/user_timeline.json"
    case statuses_update = "statuses/update.json"
    case upload_media = "media/upload.json"
}

public enum TwitterURL {
    case api
    case upload
    
    var url: URL {
        switch self {
        case .api:
            return URL(string: "https://api.twitter.com/1.1/")!
        case .upload:
            return URL(string: "https://upload.twitter.com/1.1/")!
        }
    }
}

public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
}

class TwitterAPI {
//    let baseURL = "https://api.twitter.com"
//    let version = "/1.1/"
    
    init() {
        
    }
    class func TwitterUrl(method: HTTPMethod?, path: Path?, twitterUrl: TwitterURL? , parameters: [String: String]?) -> URLRequest? {
        let user = Twitter.sharedInstance().sessionStore.session()?.userID
        let client = TWTRAPIClient(userID: user)
        
        if method == nil || path == nil {
            return nil
        }
        
        return client.urlRequest(withMethod: (method?.rawValue)!, url: (twitterUrl?.url.absoluteString)! + (path?.rawValue)!, parameters: parameters, error: NSErrorPointer.none) as URLRequest
    }

    class func getHomeTimeline(user:String?, url: URLRequest?, tweets: @escaping ([TwitterData]) -> (), error: @escaping (Error) -> ()) {
        let user = Twitter.sharedInstance().sessionStore.session()?.userID
        
        let client = TWTRAPIClient(userID: user)
        let request : URLRequest? = url
        
        if request != nil {
            client.sendTwitterRequest(request! as URLRequest, completion: {
                response, data, err in
                if err == nil {
                    var _: Error?
                    let json:AnyObject? = try! JSONSerialization.jsonObject(with: data!) as AnyObject?
                    if let jsonArray = json as? [[String: Any]] {
                        var tweet_data = [TwitterData]()
                        for tweet in jsonArray {
                            tweet_data.append(TwitterData(tweet: tweet))
                        }
                        tweets(tweet_data)
                    }else{
                        error(err!)
                    }
                }else{
                    print("request error: \(String(describing: err))")
                }
            })
        }
    }
    
    class func postNewTweet(user: String?, url: URLRequest?, result: @escaping (TwitterData) -> (), error: @escaping (Error) -> ()) {
        let user  = Twitter.sharedInstance().sessionStore.session()?.userID
        let client = TWTRAPIClient(userID: user)
        let request: URLRequest? = url
        
        if request != nil {
            client.sendTwitterRequest(request!, completion: { (response, data, err) in
                if err == nil {
                    let json: AnyObject? = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject?
                    if let jsonArray = json as? [String: Any] {
                        result(TwitterData(tweet: jsonArray))
                    } else {
                        print("request error: \(String(describing: err))")
                    }
                } else {
                    error(err!)
                }
            })
        }
    }
    
    class func postNewImage(image: Data?, result: @escaping (String?) -> (), error: @escaping (Error) -> ()) {
        let user  = Twitter.sharedInstance().sessionStore.session()?.userID
        let client = TWTRAPIClient(userID: user)
        
        if let image = image {
            client.uploadMedia(image, contentType: "image/jpeg") { (string, err) in
                result(string)
            }
        }
        
//        if request != nil {
//            client.sendTwitterRequest(request!, completion: { (response, data, err) in
//                if err == nil {
//                    let json: AnyObject? = try! JSONSerialization.jsonObject(with: data!, options: []) as AnyObject?
//                    if let jsonArray = json as? [String: Any] {
//                        result(TwitterData(tweet: jsonArray))
//                    } else {
//                        print("request error: \(String(describing: err))")
//                    }
//                } else {
//                    error(err!)
//                }
//            })
//        }
    }
}

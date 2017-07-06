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

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct TwitterApi {
    static let version = "1.1"
    static let apiRootUrl = "https://api.twitter.com/\(version)/"
    
    var store : TWTRSessionStore!
    var client : TWTRAPIClient!
    
    init(store: TWTRSessionStore) {
        self.store = store
    }
    
    private static func TwitterUrl(method: Method, parameters: [AnyHashable : Any]?) -> URL {
        return URL(string: "")!
    }
}

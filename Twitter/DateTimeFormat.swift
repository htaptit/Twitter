//
//  DateTimeFormat.swift
//  Twitter
//
//  Created by Hoang Trong Anh on 10/6/17.
//  Copyright © 2017 Hoang Trong Anh. All rights reserved.
//

import Foundation

public enum SocialTimesFomart: String {
    case twitter_date = "eee MMM dd HH:mm:ss ZZZZ yyyy"
    
    public func get() -> String {
        return self.rawValue
    }
}
public enum PopularTimeFormat: String {
    case short = "yyyy/MM/dd HH:mm"
    
    public func get() -> String {
        return self.rawValue
    }
}

public func formarted_date(date: String, from : SocialTimesFomart ,to : PopularTimeFormat) -> String {
    let _init = DateFormatter()
    _init.dateFormat = from.get()
    
    let date = _init.date(from: date)
    _init.dateFormat = to.get()
    
    return _init.string(from: date!)
}

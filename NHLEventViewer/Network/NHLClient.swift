//
//  NHLClient.swift
//  testNib
//
//  Created by Esko Jääskeläinen on 17/11/2018.
//  Copyright © 2018 Esko Jääskeläinen. All rights reserved.
//

import Foundation

enum NHLStatsFeed {
    case schedule
    case livefeed
}

extension NHLStatsFeed: Endpoint {    
    var base: String {
        return "https://statsapi.web.nhl.com"
    }
    
    var path: String {
        switch self {
        case .schedule: return "/api/v1/schedule"
        case .livefeed: return "/api/v1/game" // /2018020287/feed/live"
        }
    }
}

class ScheduleClient: NetworkClient {
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func getFeed(from feedType: NHLStatsFeed, parameters: [String: String], completion: @escaping (NetworkResult<ScheduleFeed?, NetworkError>) -> Void) {
        
        let endpoint = feedType
        let request = endpoint.request(parameters: parameters)

        fetch(with: request, decode: { json -> ScheduleFeed? in
            guard let feedType = json as? ScheduleFeed else { return  nil }
            return feedType
        }, completion: completion)
    }
}

class LiveFeedClient: NetworkClient {
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func getFeed(from feedType: NHLStatsFeed, parameters: String, completion: @escaping (NetworkResult<LiveFeed?, NetworkError>) -> Void) {
        
        let endpoint = feedType
        let request = endpoint.request(parameters: parameters)
        
        fetch(with: request, decode: { json -> LiveFeed? in
            guard let feedType = json as? LiveFeed else { return  nil }
            return feedType
        }, completion: completion)
    }
}

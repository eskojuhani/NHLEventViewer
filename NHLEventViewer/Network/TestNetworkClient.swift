//
//  TestNetworkClient.swift
//  eVakio
//
//  Created by Esko Jääskeläinen on 10/11/2018.
//  Copyright © 2018 Esko Jääskeläinen. All rights reserved.
//

import Foundation

enum TypicodeFeed {
    case users
    case todos
}

extension TypicodeFeed: Endpoint {
    var base: String {
        return "https://jsonplaceholder.typicode.com"
    }
    
    var path: String {
        switch self {
        case .users: return "/users"
        case .todos: return "/todos"
        }
    }
}

struct Geo: Decodable {
    let lat: String?
    let lng: String?
}

struct Address: Decodable {
    let street: String?
    let suite: String?
    let city: String?
    let zipcode: String?
    let geo: Geo?
}
struct Company: Decodable {
    let name: String?
    let catchPhrase: String?
    let bs: String?
}
struct User: Decodable {
    let id: Int?
    let name: String?
    let username: String?
    let email: String?
    let address: Address?
    let phone: String?
    let website: String?
    let company: Company?
}
struct Todo: Codable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}

class UserClient: NetworkClient {
    
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func getFeed(from feedType: TypicodeFeed, completion: @escaping (NetworkResult<Array<User>?, NetworkError>) -> Void) {
        
        let endpoint = feedType
        let request = endpoint.request(parameters: [:])
        
        fetch(with: request, decode: { json -> Array<User>? in
            guard let feedType = json as? Array<User> else { return  nil }
            return feedType
        }, completion: completion)
    }
}

class TodoClient: NetworkClient {
    
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    func getFeed(from feedType: TypicodeFeed, completion: @escaping (NetworkResult<Array<Todo>?, NetworkError>) -> Void) {
        
        let endpoint = feedType
        let request = endpoint.request(parameters: [:])
        
        fetch(with: request, decode: { json -> Array<Todo>? in
            guard let feedType = json as? Array<Todo> else { return  nil }
            return feedType
        }, completion: completion)
    }
}

class TestNC {
    
    private let userClient = UserClient()
    private let todoClient = TodoClient()
    
    func testUser() {
        userClient.getFeed(from: .users) { result in
            switch result {
            case .success(let feedResult):
                guard let results = feedResult else { return }
                print(results)
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
    
    func testTodos() {
        todoClient.getFeed(from: .todos) { result in
            switch result {
            case .success(let feedResult):
                guard let results = feedResult else { return }
                print(results)
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
}

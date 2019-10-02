//
//  Request.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

protocol Request {
    associatedtype Response: Decodable
    
    var baseURLs: [String] { get }
    var urlIndex: Int { set get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
    var decisions: [Decision] { set get }
    
    func baseURL() -> String
    mutating func setNextDomain()
}

extension Request {
    func baseURL() -> String {
        guard urlIndex < baseURLs.count else {
            fatalError("Index out of range")
        }
        return baseURLs[urlIndex]
    }
    
    mutating func setNextDomain() {
        urlIndex = (urlIndex + 1) % baseURLs.count
    }
}


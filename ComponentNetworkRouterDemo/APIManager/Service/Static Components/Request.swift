//
//  Request.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

protocol Request: EndPoint, DomainChangable {
    associatedtype Response: Decodable
}

extension Request {
    var baseURL: String { return baseURL() }
}

protocol EndPoint {
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}

protocol DomainChangable {
    var multiDomain: MultiDomain { set get }
    func baseURL() -> String
    mutating func setNextDomain()
}

extension DomainChangable {
    func baseURL() -> String {
        guard multiDomain.urlIndex < multiDomain.URLs.count else {
            fatalError("Index out of range")
        }
        return multiDomain.URLs[multiDomain.urlIndex]
    }
    
    mutating func setNextDomain() {
        multiDomain.urlIndex = (multiDomain.urlIndex + 1) % multiDomain.URLs.count
    }
}

struct MultiDomain {
    var URLs: [String]
    var urlIndex: Int = 0
}

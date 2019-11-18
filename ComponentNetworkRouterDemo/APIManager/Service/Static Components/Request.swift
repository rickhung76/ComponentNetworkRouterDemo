//
//  Request.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

public protocol Request: EndPoint, DomainChangable {
    
    /// Response model type
    associatedtype Response: Decodable
    
    
    /// The URLRequest object, will be assigned by build request decision.
    /// - Give nil at initial state is fine.
    var formatRequest: URLRequest? { get set }
    
    
    /// The ResponseTuple object, will be assigned by send request decision.
    /// - Give nil at initial state is fine.
    var response: ResponseTuple? { get set }
}

public extension Request {
    
    var baseURL: String { return baseURL() }
    
    mutating func setFormatRequest(_ request: URLRequest) {
        self.formatRequest = request
    }
    
    mutating func setResponse(_ data: Data?, response: URLResponse?, error: Error?){
        self.response = ResponseTuple(data: data,
                                      response: response,
                                      error: error)
    }
}

public protocol EndPoint {
    
    var baseURL: String { get }
    
    var path: String { get }
    
    var httpMethod: HTTPMethod { get }
    
    var parameters: Parameters? { get }
    
    var urlParameters: Parameters? { get }
    
    var bodyEncoding: ParameterEncoding? { get }
    
    var headers: HTTPHeaders? { get }
}

public protocol DomainChangable {
    
    var multiDomain: MultiDomain { get }
    
    func baseURL() -> String
    
    mutating func setNextDomain()
}

public extension DomainChangable {
    
    func baseURL() -> String {
        guard multiDomain.urlIndex < multiDomain.URLs.count else {
            fatalError("MultiDomain URL Index out of range")
        }
        return multiDomain.URLs[multiDomain.urlIndex]
    }
    
    mutating
    func setNextDomain() {
        multiDomain.urlIndex = (multiDomain.urlIndex + 1) % multiDomain.URLs.count
    }
}

public class MultiDomain {
    
    /// URL list for Domains
    var URLs: [String]
    
    /// urlIndex - current index for url list
    var urlIndex: Int = 0
    
    /// A class can contain mutiple domain url for Fried Tofu router to use.
    /// Will switch to next url if retry decision do apply
    public init(URLs: [String]) {
        self.URLs = URLs
    }
}

public struct ResponseTuple {
    
    /// Data from URLSession task
    public let data: Data?
    
    /// URLResponse from URLSession task
    public let response: URLResponse?
    
    /// Error from URLSession task
    public let error: Error?
}

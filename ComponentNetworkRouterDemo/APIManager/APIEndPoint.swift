//
//  APIEndPoint.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/17.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct GetVersionEndPoint: EndPointType {
    
    typealias Response = Version
    
    var baseURL: URL {
        return URL(string: "https://api.huiyouhy.com")!
    }
    
    var path: String {
        return "/api/servicer/apk/version"
    }
    
    var httpMethod: HTTPMethod {
        return .post
    }
    
    var task: HTTPTask {
        let parameters = ["Type": self.type]
        return .requestParameters(bodyParameters: parameters,
                                  bodyEncoding: .jsonEncoding,
                                  urlParameters: nil)
    }
    
    var headers: HTTPHeaders? {
        return [:]
    }
    
    let type: String
}

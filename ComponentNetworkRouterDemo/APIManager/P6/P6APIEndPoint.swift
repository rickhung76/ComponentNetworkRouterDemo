//
//  APIEndPoint.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/17.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

var domainURLs: [String] =
["https://api.huiyouhy.com",
"https://api.huiyouhy.com",
"https://api.huiyouhy.com"]

struct GetVersionRequest: Request {
    
    typealias Response = BaseResponse<Version>
    
    var urlIndex: Int = 0

    var baseURLs: [String] {
        return domainURLs //APIManager.shared.domains
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
    
    var decisions: [Decision] = Decisions.defaults
    
    let type: String
}

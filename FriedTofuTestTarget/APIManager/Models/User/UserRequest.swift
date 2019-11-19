//
//  UserRequest.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation
import FriedTofu

class UserRequest: Request {
    
    typealias Response = BaseResponse<[User]>
    
    var formatRequest: URLRequest? = nil
    
    var response: ResponseTuple? = nil
    
    var path: String {
        return "/search/users"
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var urlParameters: Parameters? {
        return ["q": userName,
                "followers": "%3E1000",
                "page": "\(page)"]
    }
    
    var bodyEncoding: ParameterEncoding? {
        return .urlEncoding
    }
    
    var headers: HTTPHeaders? {
        return ["Accept" : "application/vnd.github.v3+json"]
    }
    
    var multiDomain: MultiDomain {
        return MultiDomain(URLs: ["https://api.github.com"])
    }
    
    let userName: String
    let page: Int
    
    init(userName: String, page: Int) {
        self.userName = userName
        self.page = page
    }
}

//
//  UserRequestTest.swift
//  ComponentNetworkRouterDemoTests
//
//  Created by 黃柏叡 on 2019/10/30.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct UserRequestTest: Request {
    
    typealias Response = BaseResponse<User>
    
    var formatRequest: URLRequest? = nil
       
    var response: ResponseTuple? = nil
    
    var path: String {
        return "/users"
    }
    
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        return nil
    }
    
    var urlParameters: Parameters? {
        return nil
    }
    
    var bodyEncoding: ParameterEncoding? {
        return .jsonEncoding
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var multiDomain: MultiDomain {
        return MultiDomain(URLs: ["http://localhost:3002"])
    }
    
    
}

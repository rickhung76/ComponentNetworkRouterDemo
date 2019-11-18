//
//  ParseResultDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

public struct ParseResultDecision: Decision {
    
    public init() {}
    
    public func shouldApply<Req: Request>(request: Req) -> Bool {
        return true
    }

    public func apply<Req: Request>(request: Req, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) {
        guard let response = request.response else {
            let errRes = APIError(APIErrorCode.missingResponse.rawValue,
                                  APIErrorCode.missingResponse.description)
            completion(.errored(errRes))
            return
        }
        
        guard let data = response.data else {
            let errRes = APIError(APIErrorCode.missingData.rawValue,
                                  APIErrorCode.missingData.description)
            completion(.errored(errRes))
            return
        }
        
        do {
            let value = try JSONDecoder().decode(Req.Response.self, from: data)
            completion(.done(value))
        } catch {
            let err = APIError(APIErrorCode.unableToDecode.rawValue,
                               APIErrorCode.unableToDecode.description)
            completion(.errored(err))
        }
    }
}

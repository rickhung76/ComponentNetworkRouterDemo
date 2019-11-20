//
//  RetryDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

public struct RetryDecision: Decision {
    
    let retryCount: Int
    
    public init(retryCount: Int) {
        self.retryCount = retryCount
    }
    
    public func shouldApply<Req>(request: Req) -> Bool where Req : Request {
        guard let response = request.rawResponse,
            response.error == nil,
            let httpUrlResponse = response.response as? HTTPURLResponse,
            response.data != nil else {
            return true
        }
                
        let isStatusCodeValid = (200...299).contains(httpUrlResponse.statusCode)
        return !isStatusCodeValid
    }
    
    public func apply<Req>(request: Req, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) where Req : Request {
        
        request.setNextDomain()
        
        let retryDecision = RetryDecision(retryCount: retryCount - 1)
        
        if retryCount > 0 {
            var newDecisions = decisions.inserting(retryDecision, at: 0)
            newDecisions.insert(SendRequestDecision(), at: 0)
            newDecisions.insert(BuildRequestDecision(), at: 0)
            completion(.restartWith(request, newDecisions))
        } else {
            var errRes: APIError!
            
            guard let response = request.rawResponse else {
                errRes = APIError(APIErrorCode.missingResponse.rawValue,
                                      APIErrorCode.missingResponse.description)
                completion(.errored(errRes))
                return
            }

            if let error = response.error {
                errRes = APIError(APIErrorCode.clientError.rawValue,
                                      error.localizedDescription)
                completion(.errored(errRes))
                return
            }
            
            guard let _ = response.response as? HTTPURLResponse else {
                errRes = APIError(APIErrorCode.missingResponse.rawValue,
                                  APIErrorCode.missingResponse.description)
                completion(.errored(errRes))
                return
            }
            
            guard response.data != nil else {
                errRes = APIError(APIErrorCode.missingData.rawValue,
                                  APIErrorCode.missingData.description)
                completion(.errored(errRes))
                return
            }
            
            errRes = APIError(APIErrorCode.unknownError.rawValue,
                              APIErrorCode.unknownError.description)
            completion(.errored(errRes))
        }
    }
}

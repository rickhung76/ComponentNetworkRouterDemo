//
//  RetryDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct RetryDecision: Decision {
    let retryCount: Int
    
    func shouldApply<Req>(request: Req) -> Bool where Req : Request {
        guard let response = request.response,
            response.error == nil,
            let httpUrlResponse = response.response as? HTTPURLResponse,
            response.data != nil else {
            return true
        }
                
        let isStatusCodeValid = (200...299).contains(httpUrlResponse.statusCode)
        return !isStatusCodeValid
    }
    
    func apply<Req>(request: Req, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) where Req : Request {
        guard let response = request.response else {
            let errRes = APIError(APIErrorCode.missingResponse.rawValue,
                                  APIErrorCode.missingResponse.description)
            completion(.errored(errRes))
            return
        }
        
        var request = request
        request.setNextDomain()
        
        let retryDecision = RetryDecision(retryCount: retryCount - 1)
        let newDecisions = decisions.inserting(retryDecision, at: 0)
        if retryCount > 0 {
            completion(.restartWith(request, newDecisions))
        } else {
            var errRes: APIError!
            
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

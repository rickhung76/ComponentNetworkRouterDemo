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
    
    func shouldApply<Req>(request: Req, data: Data, response: HTTPURLResponse) -> Bool where Req : Request {
        let isStatusCodeValid = (200...299).contains(response.statusCode)
        return !isStatusCodeValid && retryCount > 0
    }
    
    func apply<Req>(request: Req, data: Data, response: HTTPURLResponse, completion: @escaping (DecisionAction<Req>) -> Void) where Req : Request {
        var request = request
        request.setNextDomain()
        let newRetryDecision = RetryDecision(retryCount: retryCount - 1)
        request.decisions.replacing(self, with: newRetryDecision)
        completion(.restartWith(request))
    }
}

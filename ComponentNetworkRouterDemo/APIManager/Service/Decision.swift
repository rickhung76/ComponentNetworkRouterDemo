//
//  Decision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

protocol Decision {
    func shouldApply<Req: EndPointType>(request: Req, data: Req.Response, response: HTTPURLResponse) -> Bool
    func apply<Req: EndPointType>(
        request: Req,
        data: Data,
        response: HTTPURLResponse,
        done closure: @escaping (DecisionAction<Req>) -> Void)
}

enum DecisionAction<Req: EndPointType> {
    case continueWith(Data, HTTPURLResponse)
    case restartWith([Decision])
    case errored(Error)
    case done(Req.Response)
}

extension Array where Element == Decision {
    func removing(_ item: Decision) -> Array {
        print("Not implemented yet.")
        return self
    }

    func replacing(_ item: Decision, with: Decision?) -> Array {
        print("Not implemented yet.")
        return self
    }
}

struct RetryDecision: Decision {
    let retryCount: Int
    
    func shouldApply<Req>(request: Req, data: Req.Response, response: HTTPURLResponse) -> Bool where Req : EndPointType {
        let isStatusCodeValid = (200...299).contains(response.statusCode)
        return !isStatusCodeValid && retryCount > 0
    }
    
    func apply<Req>(request: Req, data: Data, response: HTTPURLResponse, done closure: @escaping (DecisionAction<Req>) -> Void) where Req : EndPointType {
        let newRetryDecision = RetryDecision(retryCount: retryCount - 1)
        let newDecisions = request.decisions.replacing(self, with: newRetryDecision)
        closure(.restartWith(newDecisions))
    }
}

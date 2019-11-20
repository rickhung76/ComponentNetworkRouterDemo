//
//  SendRequestDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/11/15.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

public struct SendRequestDecision: Decision {
    
    /*
     SendRequestDecision
     將 Request 內的 formatRequest: URLRequest 傳入 URLSession 執行。
     */
    public init() {}
    
    
    /// SendRequestDecision
    /// - Parameter request: Request Protocol 的 Request
    public func shouldApply<Req>(request: Req) -> Bool where Req : Request {
        return true
    }
    
    public func apply<Req>(request: Req, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) where Req : Request {
        
        guard let formatRequest = request.formatRequest else {
            let err = APIError(APIErrorCode.missingRequest.rawValue,
                               APIErrorCode.missingRequest.description)
            completion(.errored(err))
            return
        }

        let task = URLSession.shared.dataTask(with: formatRequest, completionHandler: { data, response, error in
            request.setResponse(data, response: response, error: error)
            completion(.continueWithRequst(request))
        })

        task.resume()
    }
    
    
}

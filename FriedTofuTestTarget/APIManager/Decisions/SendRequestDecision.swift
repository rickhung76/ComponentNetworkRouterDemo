//
//  SendRequestDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/11/15.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation
import FriedTofu

struct SendRequestDecision: Decision {
    
    func shouldApply<Req>(request: Req) -> Bool where Req : Request {
        return true
    }
    
    func apply<Req>(request: Req, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) where Req : Request {
        
        guard let formatRequest = request.formatRequest else {
            let err = APIError(APIErrorCode.missingRequest.rawValue,
                               APIErrorCode.missingRequest.description)
            completion(.errored(err))
            return
        }

        let task = URLSession.shared.dataTask(with: formatRequest, completionHandler: { data, response, error in
            var request = request
            request.setResponse(data, response: response, error: error)
            completion(.continueWithRequst(request))
        })

        task.resume()
    }
    
    
}

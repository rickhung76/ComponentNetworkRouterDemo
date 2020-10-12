//
//  RefreshTokenDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct RefreshTokenDecision: Decision {
    
    func shouldApply<Req: Request>(request: Req) -> Bool  {
        guard let response = request.rawResponse,
            let httpUrlResponse = response.response as? HTTPURLResponse else {
            return true
        }
        
        return httpUrlResponse.statusCode == 401
    }
    
    func apply<Req: Request>(request: Req, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) {
        Decisions.normalQueue.suspend()
        
        //refresh token sucess implement
        
//        ApiManager.shared.refreshToken { (result) in
//            switch result {
//            case .success( _):
//                var newDecisions = decisions
//                newDecisions.insert(SendRequestDecision(isPriority: true), at: 0)
//                newDecisions.insert(BuildRequestDecision(), at: 0)
//                completion(.restartWith(request, newDecisions))
//            case .failure(let error):
//                completion(.errored(error))
//            }
//        }
        Decisions.normalQueue.resume()
        completion(.errored(APIError.init(.authenticationError)))
    }
}

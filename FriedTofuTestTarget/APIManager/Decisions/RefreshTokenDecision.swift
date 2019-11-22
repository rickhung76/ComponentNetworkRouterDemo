//
//  RefreshTokenDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation
import FriedTofu

struct RefreshTokenDecision: Decision {
    let apiClosure: (() -> Result<Bool, Error>)? 
    
    func shouldApply<Req: Request>(request: Req) -> Bool  {
        return true //TODO: CLOSE
        
        guard let response = request.rawResponse,
            let httpUrlResponse = response.response as? HTTPURLResponse else {
            return true
        }
        return httpUrlResponse.statusCode == 401
    }
    
    func apply<Req: Request>(request: Req, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) {
        //refresh token sucess implement
        guard let apiClosure = apiClosure else {
            let newDecisions = decisions.removing(self)
            completion(.restartWith(request, newDecisions))
            return
        }
        
        let apiClosureResult = apiClosure()
        switch apiClosureResult {
        case .success( _):
            let newDecisions = decisions.removing(self)
            completion(.restartWith(request, newDecisions))
        case .failure( _):
            let err = APIError(APIErrorCode.authenticationError)
            completion(.errored(err))
        }
    }
}

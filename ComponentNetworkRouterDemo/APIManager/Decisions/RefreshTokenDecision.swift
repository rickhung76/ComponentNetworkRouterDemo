//
//  RefreshTokenDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct RefreshTokenDecision: Decision {
    func shouldApply<Req: Request>(request: Req, data: Data?, response: URLResponse?, error: Error?) -> Bool  {
        guard let response = response as? HTTPURLResponse else {
            return true
        }
        return response.statusCode == 401
    }
    
    func apply<Req: Request>(request: Req, data: Data?, response: URLResponse?, error: Error?, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) {
//        var request = request
        //refresh token sucess implement
        let newDecisions = decisions.removing(self)
        completion(.restartWith(request, newDecisions))
    }
}

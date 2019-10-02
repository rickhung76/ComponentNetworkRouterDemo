//
//  RefreshTokenDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct RefreshTokenDecision: Decision {
    func shouldApply<Req: Request>(request: Req, data: Data, response: HTTPURLResponse) -> Bool  {
        return response.statusCode == 403
    }
    
    func apply<Req: Request>(request: Req, data: Data, response: HTTPURLResponse, completion: @escaping (DecisionAction<Req>) -> Void) {
        var request = request
        //refresh token sucess implement
        request.decisions.removing(self)
        completion(.restartWith(request))
    }
}

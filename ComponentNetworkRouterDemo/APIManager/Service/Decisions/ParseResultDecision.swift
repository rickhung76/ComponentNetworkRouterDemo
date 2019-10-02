//
//  ParseResultDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct ParseResultDecision: Decision {
    func shouldApply<Req: Request>(request: Req, data: Data, response: HTTPURLResponse) -> Bool {
        return true
    }

    func apply<Req: Request>(request: Req, data: Data, response: HTTPURLResponse, completion: @escaping (DecisionAction<Req>) -> Void)
    {
        do {
            let value = try JSONDecoder().decode(Req.Response.self, from: data)
            completion(.done(value))
        } catch {
            let err = APIError(APIErrorCode.unableToDecode.rawValue,
                               APIErrorCode.unableToDecode.description)
            completion(.errored(err))
        }
    }
}

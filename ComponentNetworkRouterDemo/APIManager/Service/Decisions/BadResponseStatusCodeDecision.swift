//
//  BadResponseStatusCodeDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct BadResponseStatusCodeDecision: Decision {
    func shouldApply<Req: Request>(request: Req, data: Data, response: HTTPURLResponse) -> Bool {
        return !(200...299).contains(response.statusCode)
    }
    
    func apply<Req: Request>(request: Req, data: Data, response: HTTPURLResponse, completion: @escaping (DecisionAction<Req>) -> Void) {
        let errCode = handleHttpStatus(response)
        let errRes = APIError(response.statusCode, errCode.description)
        completion(.errored(errRes))
    }
    
    fileprivate func handleHttpStatus(_ response: HTTPURLResponse) -> APIErrorCode {
        switch response.statusCode {
        case 400...499: return APIErrorCode.clientError
        case 500...599: return APIErrorCode.serverError
        default:        return APIErrorCode.unknowError
        }
    }
}

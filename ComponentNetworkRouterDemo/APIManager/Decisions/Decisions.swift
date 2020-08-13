//
//  Decision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

enum Decisions {
        
    static let defaults: [Decision] =
        [
            BuildRequestDecision(),
            SendRequestDecision(),
            RetryDecision(retryCount: 3),
            RefreshTokenDecision(apiClosure: nil),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
        ]
    
    static let refreshToken: [Decision] =
        [
            RetryDecision(retryCount: 3),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
        ]
    
    static let errorHandler: [Decision] =
        [
            RefreshTokenDecision(apiClosure: nil),
            RetryDecision(retryCount: 3)
        ]
}





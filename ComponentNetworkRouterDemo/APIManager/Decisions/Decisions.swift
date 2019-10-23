//
//  Decision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct Decisions {
    static var shared = Decisions()
    
    lazy var defaults: [Decision] =
        [
            RetryDecision(retryCount: 3),
            RefreshTokenDecision(),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
        ]
    
    lazy var refreshToken: [Decision] =
        [
            RetryDecision(retryCount: 3),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
        ]
}





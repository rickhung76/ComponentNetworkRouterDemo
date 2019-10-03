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
            RefreshTokenDecision(),
            RetryDecision(retryCount: 3),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
        ]
    
    
}





//
//  Decision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

enum Decisions {
    
    static let normalQueue = DispatchQueue(label: "normalQueue")
    static let priorityQueue = DispatchQueue(label: "priorityQueue",qos: .userInteractive)
        
    static let defaults: [Decision] =
        [
            ReachabilityDecision(),
            BuildRequestDecision(),
            SendRequestDecision(),
            RetryDecision(retryCount: 3),
            RefreshTokenDecision(),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
        ]
    
    
    static let refreshToken: [Decision] =
        [
            ReachabilityDecision(),
            BuildRequestDecision(),
            SendRequestDecision(isPriority: true),
            RetryDecision(retryCount: 3, isPriority: true),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
    ]
    
    static let errorHandler: [Decision] =
        [
            ReachabilityDecision(),
            RefreshTokenDecision(),
            RetryDecision(retryCount: 3)
        ]
}





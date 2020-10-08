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
    
    static func defaults(session: URLSession) -> [Decision] {
        return [
            ReachabilityDecision(),
            BuildRequestDecision(),
            SendRequestDecision(session: session),
            RetryDecision(retryCount: 3, session: session),
            RefreshTokenDecision(),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
        ]
    }
    
    static func refreshToken(session: URLSession) -> [Decision] {
        return [
            ReachabilityDecision(),
            BuildRequestDecision(),
            SendRequestDecision(session: session, isPriority: true),
            RetryDecision(retryCount: 3, session: session, isPriority: true),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
        ]
    }
}





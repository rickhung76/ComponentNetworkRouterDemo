//
//  Router.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

public class Router: NetworkRouter {
    private var defultDecisions: [Decision]
        
    
    
    /// Init router with default decision path
    /// - defultDecisions = 
    /// -   [
    /// -       BuildRequestDecision(),
    /// -       SendRequestDecision(),
    /// -       RetryDecision(retryCount: 3),
    /// -       BadResponseStatusCodeDecision(),
    /// -       ParseResultDecision()
    /// -   ]
    public init() {
        self.defultDecisions = [
            BuildRequestDecision(),
            SendRequestDecision(),
            RetryDecision(retryCount: 3),
            BadResponseStatusCodeDecision(),
            ParseResultDecision()
        ]
    }
    
    
    /// Init router with custom decision path
    /// - Parameter decisions: custom decision path
    public init(with decisions: [Decision]) {
        self.defultDecisions = decisions
    }
    
    
    /// Router send request
    /// - Parameter request: The Struct confirms Request protocol
    /// - Parameter decisions: Decision path for the given request. It's optional.
    /// - Parameter completion: Completion handler
    public func send<T: Request>(_ request: T, decisions: [Decision]? = nil, completion: @escaping (Result<T.Response, Error>)->()) {
        
        self.handleDecision(request: request,
                            decisions: decisions ?? defultDecisions,
                            handler: completion)

    }
    
    public func cancel() {
        debugPrint("Not implement")
//        self.task?.cancel()
    }
    
    fileprivate func handleDecision<Req: Request>(request: Req, decisions: [Decision], handler: @escaping (Result<Req.Response, Error>) -> Void) {
        guard !decisions.isEmpty else {
            fatalError("No decision left but did not reach a stop.")
        }
        
        var decisions = decisions
        let current = decisions.removeFirst()
        
        guard current.shouldApply(request: request) else {
            handleDecision(request: request,
                           decisions: decisions,
                           handler: handler)
            return
        }
        
        print("Apply Decision : \(request.path) - \(current)")
        current.apply(request: request, decisions: decisions) { action in
            switch action {
            case .continueWithRequst(let request):
                self.handleDecision(request: request,
                                    decisions: decisions,
                                    handler: handler)
            case .restartWith(let request, let decisions):
                self.send(request, decisions: decisions, completion: handler)
            case .errored(let error):
                print("\n - - - - - - - Decision Handler END with failure - - - - - - - - \n")
                handler(.failure(error))
            case .done(let value):
                print("\n - - - - - - - Decision Handler END with success - - - - - - - - \n")
                handler(.success(value))
            }
        }
    }
}

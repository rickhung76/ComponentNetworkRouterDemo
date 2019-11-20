//
//  Decision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

public protocol Decision {
        
    func shouldApply<Req: Request>(request: Req) -> Bool
    
    func apply<Req: Request>(
        request: Req,
        decisions: [Decision],
        completion: @escaping (DecisionAction<Req>) -> Void)
}

extension Decision {
    
    var description: String { return "\(type(of: self))" }
}

public enum DecisionAction<Req: Request> {
    
    case continueWithRequst(Req)
    case restartWith(Req, [Decision])
    case errored(Error)
    case done(Req.Response)
}

public extension Array where Element == Decision {
    
    @discardableResult
    func inserting(_ item: Decision, at: Int) -> Array {
        var new = self
        new.insert(item, at: at)
        return new
    }
    
    @discardableResult
    func removing(_ item: Decision) -> Array {
        var new = self
        guard let idx = new.firstIndex(where: { (decision) -> Bool in
            return decision.description == item.description
        }) else {return new}
        new.remove(at: idx)
        return new
    }

    @discardableResult
    func replacing(_ item: Decision, with: Decision?) -> Array {
        var new = self
        guard let idx = new.firstIndex(where: { (decision) -> Bool in
            return decision.description == item.description
        }) else {return new}
        new.remove(at: idx)
        if let newItem = with { new.insert(newItem, at: idx) }
        return new
    }
}

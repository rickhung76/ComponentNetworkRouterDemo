//
//  Decision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

protocol Decision {
    var description: String {get}
    func shouldApply<Req: Request>(request: Req, data: Data, response: HTTPURLResponse) -> Bool
    func apply<Req: Request>(
        request: Req,
        data: Data,
        response: HTTPURLResponse,
        decisions: [Decision],
        completion: @escaping (DecisionAction<Req>) -> Void)
}

extension Decision {
    var description: String { return "\(type(of: self))" }
}

enum DecisionAction<Req: Request> {
    case continueWithData(Data, HTTPURLResponse)
    case restartWith(Req, [Decision])
    case errored(Error)
    case done(Req.Response)
}

extension Array where Element == Decision {
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
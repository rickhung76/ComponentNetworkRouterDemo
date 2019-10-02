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
        completion: @escaping (DecisionAction<Req>) -> Void)
}

extension Decision {
    var description: String { return "\(type(of: self))" }
}

enum DecisionAction<Req: Request> {
    case continueWithData(Data, HTTPURLResponse)
    case restartWith(Req)
    case errored(Error)
    case done(Req.Response)
}

extension Array where Element == Decision {
    @discardableResult
    mutating func removing(_ item: Decision) -> Array {
        guard let idx = self.firstIndex(where: { (decision) -> Bool in
            return decision.description == item.description
        }) else {return self}
        self.remove(at: idx)
        return self
    }

    @discardableResult
    mutating func replacing(_ item: Decision, with: Decision?) -> Array {
        guard let idx = self.firstIndex(where: { (decision) -> Bool in
            return decision.description == item.description
        }) else {return self}
        self.remove(at: idx)
        if let new = with { self.insert(new, at: idx) }
        return self
    }
}

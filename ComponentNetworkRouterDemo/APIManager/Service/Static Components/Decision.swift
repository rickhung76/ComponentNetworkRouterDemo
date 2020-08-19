//
//  Decision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/1.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

/// Decision is the unit for every action which will be handled by router.
/// Decision 可視為流程圖上每一個邏輯單元，而 Router 將會對一連串的邏輯單元（Decision Array）進行操作
public protocol Decision {
        
    /// ShouldApply handles the logic to determine whether this decision will be excute.
    /// Can always return true if necessary.
    /// If return false, the current decision will be skiped.
    /// ShouldApply 為一布林值，表述當前 Decision 是否被執行或是跳過，
    /// 若某 Decision 為必須執行步驟，可直接 return true。
    ///
    /// - Parameter request: The class confirms Request protocol.
    func shouldApply<Req: Request>(request: Req) -> Bool
    
    
    /// The actual logic this decision will handle in the flow.
    /// 實際的邏輯內容存放位置
    ///
    /// - Parameter request: The class confirms Request protocol.
    /// - Parameter decisions: The decision flow will then be execute after this dicision has apply successfully.
    /// - Parameter completion: The completion handler has to carry a Decision Action with associated Request Class.
    func apply<Req: Request>(
        request: Req,
        decisions: [Decision],
        completion: @escaping (DecisionAction<Req>) -> Void)
}

extension Decision {
    
    var description: String { return "\(type(of: self))" }
}


/// DecisionAction 為每個 Decision 單元執行結束後返回之狀態
public enum DecisionAction<Req: Request> {
    
    /*** 該 Decision PASS，接續往下一個 Decision 邏輯單元做判斷 */
    case continueWithRequst(Req)
    /*** 該 Decision 要求當前 Request 需重新執行，並指定一系列 Decision 邏輯單元為新執行流程 */
    case restartWith(Req, [Decision])
    /*** 該 Decision FAIL，必須返回一錯誤訊息並終止流程 */
    case errored(APIError)
    /*** 該 Decision PASS，且為流程中最後一個邏輯單元，並傳出 Reponse 轉換出的 Data Model 返回 Router
     * 並結束這一系列流程 */
    case done(Req.Response?)
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

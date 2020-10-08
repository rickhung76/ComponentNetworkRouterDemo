//
//  SendRequestDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/11/15.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

public class SendRequestDecision: Decision, ProgressUpdatable {
    
    weak var delegate: SessionTaskProgressDelegate?
    
    private let session: URLSession
    
    let isPriority: Bool
    /*
     SendRequestDecision
     將 Request 內的 formatRequest: URLRequest 傳入 URLSession 執行。
     */
    init(session: URLSession, isPriority: Bool = false) {
        self.session = session
        self.isPriority = isPriority
    }
    
    
    /// SendRequestDecision
    /// - Parameter request: Request Protocol 的 Request
    public func shouldApply<Req>(request: Req) -> Bool where Req : Request {
        return true
    }
    
    public func apply<Req>(request: Req, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) where Req : Request {
        
        guard let formatRequest = request.formatRequest else {
            let err = APIError(APIErrorCode.missingRequest.rawValue,
                               APIErrorCode.missingRequest.description)
            completion(.errored(err))
            return
        }
        
        guard request.isValid else {
            let err = APIError(APIErrorCode.unknownError.rawValue,
                               APIErrorCode.unknownError.description)
            completion(.errored(err))
            return
        }
        
        let queue = isPriority ? Decisions.priorityQueue : Decisions.normalQueue
        queue.async {
            var observation: NSKeyValueObservation?
            
            let task = self.session.dataTask(with: formatRequest) { data, response, error in
                request.setResponse(data, response: response, error: error)
                completion(.continueWithRequst(request))
                observation?.invalidate()
            }
            
            observation = task.progress.observe(\.fractionCompleted, changeHandler: { [weak self] (progress: Progress, _) in
                self?.delegate?.sessionTask(request, with: progress.fractionCompleted)
            })
            
            request.task = task
            task.resume()
        }
    }
}

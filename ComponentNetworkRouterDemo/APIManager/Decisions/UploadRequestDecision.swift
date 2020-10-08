//
//  UploadRequestDecision.swift
//  ProjectSApp
//
//  Created by 黃柏叡 on 2020/4/23.
//  Copyright © 2020 Frank Chen. All rights reserved.
//

import Foundation


public class UploadRequestDecision: Decision, ProgressUpdatable {
    
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
    weak var delegate: SessionTaskProgressDelegate?
    
    let isPriority: Bool
    /*
     SendRequestDecision
     將 Request 內的 formatRequest: URLRequest 傳入 URLSession 執行。
     */
    init(isPriority: Bool = false) {
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
        
        let queue = isPriority ? ApiManager.shared.priorityQueue : ApiManager.shared.normalQueue
        queue.async {
            var observation: NSKeyValueObservation?
            
            let task = self.session.uploadTask(with: formatRequest, from: formatRequest.httpBody) { data, response, error in
                request.setResponse(data, response: response, error: error)
                completion(.continueWithRequst(request))
                observation?.invalidate()
            }
            
            observation = task.progress.observe(\.fractionCompleted, changeHandler: { [weak self] (progress: Progress, _) in
                self?.delegate?.sessionTask(request, with: progress.fractionCompleted)
            })
            
            task.resume()
        }
    }
}

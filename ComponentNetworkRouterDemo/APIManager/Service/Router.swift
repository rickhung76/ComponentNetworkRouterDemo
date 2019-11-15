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
    private var task: URLSessionTask?
    private var timeoutInterval = 10.0
    
    public init(_ decisions: [Decision]) {
        self.defultDecisions = decisions
    }
    
    public func send<T: Request>(_ request: T, decisions: [Decision]? = nil, completion: @escaping (Result<T.Response, Error>)->()) {
        let session = URLSession.shared
        do {
            let formatRequest = try self.buildRequest(from: request)
            APILogger.log(request: formatRequest)
            task = session.dataTask(with: formatRequest, completionHandler: { [weak self, decisions] data, response, error in
                guard let self = self else {return}
                
                self.handleDecision(request: request,
                                    data: data,
                                    response: response,
                                    error: error,
                                    decisions: decisions ?? self.defultDecisions,
                                    handler: completion)
            })
        } catch {
            let errRes = APIError(APIErrorCode.clientError.rawValue,
                                  error.localizedDescription)
            completion(.failure(errRes))
        }
        self.task?.resume()
    }
    
    public func cancel() {
        self.task?.cancel()
    }
    
    fileprivate func buildRequest<T: Request>(from route: T) throws -> URLRequest {
        var request = URLRequest(url: URL(string: route.baseURL + "\(route.path)")!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        
        request.httpMethod = route.httpMethod.rawValue
        do {
            if(route.bodyEncoding == nil) {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } else {
                try self.configureParameters(bodyParameters: route.parameters,
                                             bodyEncoding: route.bodyEncoding!,
                                             urlParameters: route.urlParameters,
                                             request: &request)
            }
            
            if let additionalHeaders = route.headers {
                self.addAdditionalHeaders(additionalHeaders, request: &request)
            }
            
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    fileprivate func handleDecision<Req: Request>(request: Req, data: Data?, response: URLResponse?, error: Error?, decisions: [Decision], handler: @escaping (Result<Req.Response, Error>) -> Void) {
        guard !decisions.isEmpty else {
            fatalError("No decision left but did not reach a stop.")
        }
        
        var decisions = decisions
        let current = decisions.removeFirst()
        guard current.shouldApply(request: request, data: data, response: response, error: error) else {
            handleDecision(request: request,
                           data: data,
                           response: response,
                           error: error,
                           decisions: decisions,
                           handler: handler)
            return
        }
        print("Apply Decision : \(request.path) - \(current)")
        current.apply(request: request, data: data, response: response, error: error, decisions: decisions) { action in
            switch action {
            case .continueWithData(let data, let response):
                self.handleDecision(request: request,
                                    data: data,
                                    response: response,
                                    error: error,
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

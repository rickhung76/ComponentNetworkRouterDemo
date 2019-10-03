//
//  Router.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/9/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

class Router: NetworkRouter {
    private var task: URLSessionTask?
    private var timeoutInterval = 10.0
    
    func send<T: Request>(_ request: T, decisions: [Decision]? = nil, completion: @escaping (Result<T.Response, Error>)->()) {
        let session = URLSession.shared
        do {
            let formatRequest = try self.buildRequest(from: request)
            APILogger.log(request: formatRequest)
            task = session.dataTask(with: formatRequest, completionHandler: { [weak self] data, response, error in
                guard let self = self else {return}
                
                guard let response = response as? HTTPURLResponse else {
                    let errRes = APIError(APIErrorCode.missingResponse.rawValue,
                                          APIErrorCode.missingResponse.description)
                    completion(.failure(errRes))
                    return
                }
                
                if let error = error {
                    let errRes = APIError(response.statusCode,
                                          error.localizedDescription)
                    completion(.failure(errRes))
                    return
                }
                
                guard let data = data else {
                    let errRes = APIError(APIErrorCode.missingData.rawValue,
                                          APIErrorCode.missingData.description)
                    completion(.failure(errRes))
                    return
                }

                self.handleDecision(request: request,
                                    data: data,
                                    response: response,
                                    decisions: decisions ?? Decisions.shared.defaults,
                                    handler: completion)
            })
        } catch {
            let errRes = APIError(APIErrorCode.clientError.rawValue,
                                  error.localizedDescription)
            completion(.failure(errRes))
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    fileprivate func buildRequest<T: Request>(from route: T) throws -> URLRequest {
        var request = URLRequest(url: URL(string: route.baseURL() + "\(route.path)")!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
                
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):
                
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
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
    
    fileprivate func handleDecision<Req: Request>(request: Req, data: Data, response: HTTPURLResponse, decisions: [Decision], handler: @escaping (Result<Req.Response, Error>) -> Void) {
        guard !decisions.isEmpty else {
            fatalError("No decision left but did not reach a stop.")
        }

        var decisions = decisions
        let current = decisions.removeFirst()
        print("\(request.path): \(current)")
        guard current.shouldApply(request: request, data: data, response: response) else {
            handleDecision(request: request,
                           data: data,
                           response: response,
                           decisions: decisions,
                           handler: handler)
            return
        }
        print("---------- \(current) do Apply")
        current.apply(request: request, data: data, response: response, decisions: decisions) { action in
            switch action {
            case .continueWithData(let data, let response):
                self.handleDecision(request: request,
                                    data: data,
                                    response: response,
                                    decisions: decisions,
                                    handler: handler)
            case .restartWith(let request, let decisions):
                self.send(request, decisions: decisions, completion: handler)
            case .errored(let error):
                handler(.failure(error))
            case .done(let value):
                handler(.success(value))
            }
        }
    }
}

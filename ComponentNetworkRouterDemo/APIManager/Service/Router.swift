//
//  Router.swift
//  TestProject
//
//  Created by Ike Ho on 2019/5/13.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

struct RequestQueue<T>{
    fileprivate var requestDic = [URLRequest: T]()
    
    public var isEmpty: Bool {
        return requestDic.isEmpty
    }
    
    public var count: Int {
        return requestDic.count
    }
    
    public mutating func enqueue(_ request: URLRequest, _ element: T) {
        requestDic[request] = element
    }
    
    @discardableResult
    public mutating func dequeue(_ request: URLRequest) -> T? {
        if isEmpty {
            return nil
        } else {
            let element = requestDic[request]
            requestDic.removeValue(forKey: request)
            return element
        }
    }
}

class Router: NetworkRouter, DomainChangeable {
    private var task: URLSessionTask?
    private var timeoutInterval = 10.0
    weak var delegate: DomainChangeableDelegate?
    
    func request<T: EndPointType>(_ route: T, completion: @escaping (Result<T.Response, Error>)->()) {
        let session = URLSession.shared
        do {
            let request = try self.buildRequest(from: route)
            NetworkLogger.log(request: request)
            task = session.dataTask(with: request, completionHandler: { [request] data, response, error in
                
                if let error = error {
                    let errRes = ErrorResponse(101, error.localizedDescription)
                    completion(.failure(errRes))
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    let errRes = ErrorResponse(101, NetworkError.missingResponse.rawValue)
                    completion(.failure(errRes))
                    return
                }
                
                if let error = self.handleHttpStatus(response) {
                    let errRes = ErrorResponse(response.statusCode, error.localizedDescription)
                    completion(.failure(errRes))
                    return
                }
                
                guard let data = data else {
                    let errRes = ErrorResponse(101, NetworkError.missingData.rawValue)
                    completion(.failure(errRes))
                    return
                }

                completion(.success())
            })
        } catch {
            self.setNextDomain()
            let errRes = ErrorResponse(101, error.localizedDescription)
            completion(.failure(errRes))
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
//    fileprivate func retryRequest(_ request: URLRequest) -> Bool {
//        self.setNextDomain()
//        if retryCount >= maxRetryCount {
//            self.requestQueue.dequeue(request)
//            retryCount = 0
//            return false
//        } else {
//            retryCount += 1
//            guard let (retryRoute, retryCompletion) = requestQueue.dequeue(request) else {
//                retryCount = 0
//                return false
//            }
//            self.request(retryRoute, completion: retryCompletion)
//            return true
//        }
//    }
    
    fileprivate func buildRequest<T: EndPointType>(from route: T) throws -> URLRequest {
        var request = URLRequest(url: URL(string: route.baseURL.absoluteString + "\(route.path)")!,
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
    
    fileprivate func handleHttpStatus(_ response: HTTPURLResponse) -> Error? {
        switch response.statusCode {
        case 200...299: return nil
        case 400...500: return NetworkStatusError.authenticationError
        case 501...599: return NetworkStatusError.badRequest
        case 600:       return NetworkStatusError.outdated
        default:        return NetworkStatusError.failed
        }
    }
    
    func handleDecision<Req: EndPointType>(
        _ request: Req,
        data: Data,
        response: HTTPURLResponse,
        decisions: [Decision],
        handler: @escaping (Result<Req.Response, Error>) -> Void)
    {
        guard !decisions.isEmpty else {
            fatalError("No decision left but did not reach a stop.")
        }

        var decisions = decisions
        let current = decisions.removeFirst()

        guard current.shouldApply(request: request, data: data, response: response) else {
            handleDecision(request, data: data, response: response, decisions: decisions, handler: handler)
            return
        }

        current.apply(request: request, data: data, response: response) { action in
            switch action {
            case .continueWith(let data, let response):
                self.handleDecision(
                    request, data: data, response: response, decisions: decisions, handler: handler)
            case .restartWith(let decisions):
                self.send(request, decisions: decisions, handler: handler)
            case .errored(let error):
                handler(.failure(error))
            case .done(let value):
                handler(.success(value))
            }
        }
    }
}

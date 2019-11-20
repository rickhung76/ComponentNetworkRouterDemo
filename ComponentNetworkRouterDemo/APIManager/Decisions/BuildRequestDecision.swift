//
//  BuildRequestDecision.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/11/15.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

public struct BuildRequestDecision: Decision {
    
    let timeoutInterval = 10.0
    
    public init() {}
    
    public func shouldApply<Req>(request: Req) -> Bool where Req : Request {
        return true
    }
    
    public func apply<Req>(request: Req, decisions: [Decision], completion: @escaping (DecisionAction<Req>) -> Void) where Req : Request {
        
        do {
            let formatRequest = try buildRequest(from: request)
            request.setFormatRequest(formatRequest)
            APILogger.log(request: formatRequest)
            completion(.continueWithRequst(request))
        } catch {
            let err = APIError(APIErrorCode.encodingFailed.rawValue,
                               APIErrorCode.encodingFailed.description,
                               error.localizedDescription)
            completion(.errored(err))
        }
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
}

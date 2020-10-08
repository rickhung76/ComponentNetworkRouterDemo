//
//  ParameterEncoding.swift
//  TestProject
//
//  Created by Ike Ho on 2019/5/13.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]

struct FormBodyParameterEncoder: ParameterEncoder {
    
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) {
        
        let allowedCharacter = CharacterSet.letters.union(.decimalDigits)
        var httpBody: String = ""
        
        for (key,value) in parameters {
            let percentEncodingValue = (value as! String).addingPercentEncoding(withAllowedCharacters: allowedCharacter)!
            httpBody = httpBody.count == 0 ? "\(key)=\(percentEncodingValue)" : "\(httpBody)&\(key)=\(percentEncodingValue)"
        }
        
        urlRequest.httpBody = httpBody.data(using: .utf8)
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
    }
}

struct FormDataParameterEncoder: ParameterEncoder {
    
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) {
        let boundary = "\(UUID().uuidString)"
        var httpBody = Data()
        
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in parameters {
            if let mediaData = value as? Data {
                guard let type = Swime.mimeType(data: mediaData) else {continue}
                httpBody.encodeWith(string: "--\(boundary)\r\n")
                httpBody.encodeWith(string: "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).\(type.ext)\"\r\n")
                httpBody.encodeWith(string: "Content-Type: \(type.mime)\r\n")
                httpBody.encodeWith(string: "\r\n")
                httpBody.append(mediaData)
                httpBody.encodeWith(string: "\r\n")
            }
            else {
                httpBody.encodeWith(string: "--\(boundary)\r\n")
                httpBody.encodeWith(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n")
                httpBody.encodeWith(string: "\r\n")
                httpBody.encodeWith(string: "\(value)")
                httpBody.encodeWith(string: "\r\n")
            }
        }
        httpBody.encodeWith(string: "--\(boundary)--\r\n")
        urlRequest.httpBody = httpBody
    }
}


struct URLParameterEncoder: ParameterEncoder {
    
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        
        guard let url = urlRequest.url else {
            throw APIError(APIErrorCode.missingURL.rawValue,
                           APIErrorCode.missingURL.description)
        }
        
        if var urlComponents = URLComponents(url: url,
                                             resolvingAgainstBaseURL: false),
            !parameters.isEmpty {
            
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key,value) in parameters {
                let queryItem = URLQueryItem(name: key,
                                             value: "\(value)")
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
    }
}

struct JSONParameterEncoder: ParameterEncoder {
    
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters,
                                                        options: .prettyPrinted)
            urlRequest.httpBody = jsonAsData
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }catch {
            throw APIError(APIErrorCode.encodingFailed.rawValue,
                           APIErrorCode.encodingFailed.description)
        }
    }
}

protocol ParameterEncoder {
    
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

public enum ParameterEncoding {
    
    case urlEncoding
    case formBodyEncoding
    case formDataEncoding
    case jsonEncoding
    case urlAndJsonEncoding
    
    public func encode(urlRequest: inout URLRequest,
                       bodyParameters: Parameters?,
                       urlParameters: Parameters?) throws {
        do {
            switch self {
            case .urlEncoding:
                guard let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
            
            case .formBodyEncoding:
                guard let bodyParameters = bodyParameters else { return }
                FormBodyParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
                
            case .formDataEncoding:
                guard let bodyParameters = bodyParameters else { return }
                FormDataParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
                
            case .jsonEncoding:
                guard let bodyParameters = bodyParameters else { return }
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
                
            case .urlAndJsonEncoding:
                guard let bodyParameters = bodyParameters,
                    let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
                
            }
        }catch {
            throw error
        }
    }
}

extension Data {
    mutating func encodeWith(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

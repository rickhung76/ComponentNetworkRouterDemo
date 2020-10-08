//
//  APILogger.swift
//  TestProject
//
//  Created by Ike Ho on 2019/5/13.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

class APILogger {
    static func log(request: URLRequest) {
        
        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - - OUTGOING END - - - - - - - - - - \n") }
        
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = urlComponents?.query != nil ? "?\(urlComponents?.query ?? "")" : ""
        let host = "\(urlComponents?.host ?? "")"
        
        var logOutput = "\(urlAsString) \n\n\(method) \(path)\(query) HTTP/1.1 \nHOST: \(host)\n"
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            logOutput += "\n\(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }
        
        print(logOutput)
    }
    
    static func log(response: HTTPURLResponse, data: Data? = nil) {
        print("\n - - - - - - - - - - INCOMING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - - INCOMING END - - - - - - - - - - \n") }
        print(response.url ?? "")
        print(response.statusCode)
        for (key, value) in response.allHeaderFields {
            print("[\(key) : \(value)]")
        }
        if let data = data {
            print("\nData:")
            print(String(data: data, encoding: .utf8) ?? "cannot encode to UTF8 string")
        }
    }
    
    static func log(data: Data) {
        print("\n - - - - - - - - - - INCOMING DATA - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - - INCOMING DATA END - - - - - - - - - - \n") }
        print("\nData:")
        print(String(data: data, encoding: .utf8) ?? "cannot encode to UTF8 string")
        
    }
}

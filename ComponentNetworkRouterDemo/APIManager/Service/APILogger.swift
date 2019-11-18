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
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
        
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
    
    static func log(response: URLResponse) {}
}

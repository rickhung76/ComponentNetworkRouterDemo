//
//  ErrorResponse.swift
//  P6
//
//  Created by 黃柏叡 on 2019/9/17.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

struct ErrorResponse: Error, LocalizedError {
    let statusCode: Int
    let message: String
    let details: String?
    
    init(_ code: Int, _ message: String, _ details: String? = nil) {
        self.statusCode = code
        self.message = message
        self.details = details
    }
    
    var errorDescription: String? {
        return self.message
    }
}

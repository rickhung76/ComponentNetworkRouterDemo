//
//  JSONDecoder+Extension.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2020/10/6.
//  Copyright © 2020 黃柏叡. All rights reserved.
//

import Foundation


extension JSONDecoder {
    
    func decodeIfPresent<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        
        do {
            let value = try self.decode(type, from: data)
            return value
        } catch {
            // DO NOT FIX IT !!!
            if let nil_T = Optional<T>.none as? T {
                return nil_T
            } else {
                throw APIError(APIErrorCode.unableToDecode.rawValue,
                               APIErrorCode.unableToDecode.description)
            }
        }
    }
}

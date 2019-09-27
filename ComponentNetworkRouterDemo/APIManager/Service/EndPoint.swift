//
//  EndPoint.swift
//  TestProject
//
//  Created by Ike Ho on 2019/5/13.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

protocol EndPointType {
    associatedtype Response: Decodable
    
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
    var decisions: [Decision] { get }
}

extension EndPointType {
    var decisions: [Decision] { return [] }
}

//
//  BaseResponse.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let incompleteResults: Bool
    let totalCount: Int
    let items: T?

    
    enum CodingKeys: String, CodingKey {
        case incompleteResults = "incomplete_results"
        case totalCount = "total_count"
        case items = "items"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        incompleteResults = try container.decode(Bool.self, forKey: .incompleteResults)
        totalCount = try container.decode(Int.self, forKey: .totalCount)
        items = try? container.decode(T.self, forKey: .items)
    }
}

//
//  User.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/23.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

struct User: Decodable {
    let login: String
    let id: Int
    let avatar_url: String
    let url: String
}

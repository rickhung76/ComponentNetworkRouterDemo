//
//  Version.swift
//  P6
//
//  Created by 黃柏叡 on 2019/9/17.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

struct Version: Decodable {
    let ID: Int
    let CreatedAt: String
    let UpdatedAt: String
    let Name: String
    let Version: Int
    let DownloadURL: String
    let Desc: String
    let Force: Bool
}

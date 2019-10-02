//
//  BaseResponse.swift
//  P6
//
//  Created by 黃柏叡 on 2019/9/17.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

struct BaseResponse<T: Decodable>: Decodable {
    let Code: Int
    let Msg: String
    let Data: T?
}

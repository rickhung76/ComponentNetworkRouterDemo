//
//  NetworkRouter.swift
//  P6
//
//  Created by 黃柏叡 on 2019/9/21.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

protocol NetworkRouter: class {
    func send<T:Request>(_ route: T, decisions: [Decision]?, completion: @escaping (Result<T.Response,Error>)->())
    func cancel()
}

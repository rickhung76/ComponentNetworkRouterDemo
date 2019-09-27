//
//  NetworkRouter.swift
//  P6
//
//  Created by 黃柏叡 on 2019/9/21.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

public typealias RouterCompletion = (Result<Data,Error>)->()

protocol NetworkRouter: class {
    func request<T:EndPointType>(_ route: T, completion: @escaping (Result<T.Response,Error>)->())
    func cancel()
}

protocol DomainChangeableDelegate: class {
    func setNextDomain()
}

protocol DomainChangeable {
    var delegate: DomainChangeableDelegate? {set get}
    func setNextDomain()
}

extension DomainChangeable {
    func setNextDomain() {
        self.delegate?.setNextDomain()
    }
}

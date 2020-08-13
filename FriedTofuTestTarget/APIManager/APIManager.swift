//
//  APIManager.swift
//  FriedTofuManager
//
//  Created by 黃柏叡 on 2019/11/15.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation
import FriedTofu

class APIManager {
    
    static let shared = APIManager()
    lazy var router = Router()
}

extension APIManager {
    
    func requestGithubSearchUser(text: String, page: Int, completion: @escaping((Result<BaseResponse<[User]>,APIError>)->())) {
        let req = UserRequest(userName: text, page: 0)
        router.send(req) { (result) in
            switch result {
            case .success(let model):
                completion(.success(model))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

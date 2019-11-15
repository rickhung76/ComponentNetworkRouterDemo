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
    
    lazy var decisions = Decisions.shared.defaults
    
    lazy var router = Router(decisions)
    
    
}

extension APIManager {
    
    func requestGithubSearchUser(text: String, page: Int, completion: @escaping((Result<User,Error>)->())) {
        let req = UserRequest(userName: text, page: 0)
        router.send(req) { (result) in
            print(result)
            switch result {
            case .success(let users):
                print(users)
            case .failure(let error):
                print(error)
            }
        }
    }
}

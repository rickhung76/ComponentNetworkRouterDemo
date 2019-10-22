//
//  ApiManager.swift
//  ComponentNetworkRouterDemo
//
//  Created by 黃柏叡 on 2019/10/2.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import Foundation

class ApiManager {
    static let shared = ApiManager()
    let router = Router()

    lazy var domains: [String] = {
            return ["https://www.zxfast.com"]
    }()
    
    
    private func handleTokenError(_ msg: String) {
        DispatchQueue.main.async {
            //TODO: handleTokenError
        }
    }
    
    func transformResponse<T:Decodable>(_ result: Result<BaseResponse<T>, Error>, completion: @escaping (_ result: Result<T, APIError>) -> ()) {
        switch result {
        case .success(let apiResponse):
            do {
                if let data = apiResponse.data  {
                    completion(.success(data))
                }
                else {
                    let emptyJson = try JSONDecoder().decode(T.self, from: "{}".data(using: .utf8)!)
                    completion(.success(emptyJson))
                }
            } catch {
                print(error)
                let err = APIError(APIErrorCode.unableToDecode.rawValue,
                                   error.localizedDescription)
                completion(.failure(err))
            }
        case .failure(let error):
            let responseErr = (error as? APIError) ?? APIError(APIErrorCode.unknowError.rawValue,
                                                               error.localizedDescription)
            completion(.failure(responseErr))
        }
    }
}




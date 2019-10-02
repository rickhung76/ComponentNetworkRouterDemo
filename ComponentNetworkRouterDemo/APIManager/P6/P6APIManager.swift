//
//  APIManager.swift
//  P6
//
//  Created by 黃柏叡 on 2019/9/17.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

class P6APIManager {
    static let shared = P6APIManager()
    let router = Router()

    lazy var domains: [String] = {
            return ["https://api.zwq26.com/qralipay-console",
                    "https://api.liufuqp.com/qralipay-console",
                    "https://api.muller25.com/qralipay-console"]
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
                guard (200...299).contains(apiResponse.Code) else {
                    if apiResponse.Code == 9999 { // Token error, logout
                        self.handleTokenError(apiResponse.Msg)
                    }
                    else {
                        let err = APIError(apiResponse.Code, apiResponse.Msg, apiResponse.Msg)
                        completion(.failure(err))
                    }
                    return
                }
                if let data = apiResponse.Data  {
                    completion(.success(data))
                }
                else {
                    let emptyJson = try JSONDecoder().decode(T.self, from: "{}".data(using: .utf8)!)
                    completion(.success(emptyJson))
                }
            } catch {
                print(error)
                let err = APIError(101, error.localizedDescription, error.localizedDescription)
                completion(.failure(err))
            }
        case .failure(let error):
            let responseErr = (error as? APIError) ?? APIError(101, error.localizedDescription, error.localizedDescription)
            completion(.failure(responseErr))
        }
    }
}

extension P6APIManager{
    func getVersion(completion: @escaping (_ result: Result<Version, APIError>) -> ()){
        let request = GetVersionRequest(type: "new_ios_wallet")
        router.send(request) { (result) in
            self.transformResponse(result) { (result: Result<Version, APIError>) in
                switch result {
                case .success(let model):
                    completion(.success(model))
                case .failure(let error):
                    let err = APIError(101, error.localizedDescription)
                    completion(.failure(err))
                }
            }
        }        
    }
}

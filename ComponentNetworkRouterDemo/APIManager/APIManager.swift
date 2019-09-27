//
//  APIManager.swift
//  P6
//
//  Created by 黃柏叡 on 2019/9/17.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

enum ResponseResult<String> {
    case success
    case failure(String)
}

class APIManager {
    static let shared = APIManager()
//    let router = Router<EndPointType>()
    let router = Router()
    
    var baseURL : String {
        return domains[currentDomainIndex]
    }
    
    lazy var domains: [String] = {
            return ["https://api.zwq26.com/qralipay-console",
                    "https://api.liufuqp.com/qralipay-console",
                    "https://api.muller25.com/qralipay-console"]
    }()
    
    private var currentDomainIndex = 0
    
    init() {
        self.router.delegate = self
    }
    
    func set2NextDomain() {
        self.currentDomainIndex = currentDomainIndex + 1
        if(self.currentDomainIndex >= self.domains.count) {
            self.currentDomainIndex = 0
        }
    }
    
    private func handleTokenError(_ msg: String) {
        DispatchQueue.main.async {
            //TODO: handleTokenError
        }
    }
    
    func transformResponse<T:Decodable>(_ result: Result<Data, Error>, completion: @escaping (_ result: Result<T, ErrorResponse>) -> ()) {
        switch result {
        case .success(let data):
            do {
                print(String(data: data, encoding: .utf8) ?? data)
                let apiResponse = try JSONDecoder().decode(BaseResponse<T>.self, from: data)
                guard (200...299).contains(apiResponse.Code) else {
                    if apiResponse.Code == 9999 { // Token error, logout
                        self.handleTokenError(apiResponse.Msg)
                    }
                    else {
                        let err = ErrorResponse(apiResponse.Code, apiResponse.Msg, apiResponse.Msg)
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
                let err = ErrorResponse(101, error.localizedDescription, error.localizedDescription)
                completion(.failure(err))
            }
        case .failure(let error):
            let responseErr = (error as? ErrorResponse) ?? ErrorResponse(101, error.localizedDescription, error.localizedDescription)
            completion(.failure(responseErr))
        }
    }
}

extension APIManager{
    func getVersion(completion: @escaping (_ result: Result<Version, ErrorResponse>) -> ()){
        let endPoint = GetVersionEndPoint(type: "new_wallet")
        router.request(endPoint) { (result) in
            switch result {
            case .success(let model):
                completion(.success(model))
            case .failure(let error):
                let err = ErrorResponse(101, error.localizedDescription)
                completion(.failure(err))
            }
//            self.transformResponse(result, completion: { (result: Result<Version, ErrorResponse>) in
//                switch result {
//                case .success(let model):
//                    completion(.success(model))
//                case .failure(let error):
//                    completion(.failure(error))
//                }
//            })
        }        
    }
}


extension APIManager: DomainChangeableDelegate {
    func setNextDomain() {
        self.set2NextDomain()
    }
}

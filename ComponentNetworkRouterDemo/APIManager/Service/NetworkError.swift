//
//  NetworkError.swift
//  P6
//
//  Created by 黃柏叡 on 2019/9/17.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import Foundation

public enum NetworkError: String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
    case missingResponse = "Response is nil"
    case responseStatusError = "Response Status Error"
    case missingData = "Data is nil"
}

public enum NetworkStatusError: String, Error {
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
}

public enum NetworkResponseError: String, Error {
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}


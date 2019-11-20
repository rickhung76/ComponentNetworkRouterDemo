//
//  RetryDecisionTests.swift
//  ComponentNetworkRouterDemoTests
//
//  Created by 黃柏叡 on 2019/11/20.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import XCTest

class RetryDecisionTests: XCTestCase {
    
    struct TestResponseModel: Decodable {}
    
    class TestRequest: Request {
        
        typealias Response = TestResponseModel
        
        var formatRequest: URLRequest? = nil
        
        var rawResponse: RawResponseTuple? = nil
        
        var path: String {
            return "/test"
        }
        
        var httpMethod: HTTPMethod {
            return .post
        }
        
        var parameters: Parameters? {
            return nil
        }
        
        var urlParameters: Parameters? {
            return nil
        }
        
        var bodyEncoding: ParameterEncoding? {
            return nil
        }
        
        var headers: HTTPHeaders? {
            return nil
        }
        
        var multiDomain: MultiDomain = .init(URLs: ["https://unitest.RetryDecisionTests.url.0",
                                                    "https://unitest.RetryDecisionTests.url.1",
                                                    "https://unitest.RetryDecisionTests.url.2"])
    }
    
    var request = TestRequest()
    let decision = RetryDecision(retryCount: 3)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testApply() {
        decision.apply(request: request, decisions: []) { (action) in
            switch action {
            case .restartWith(let request, let decisions):
                guard decisions.count > 0 else {
                    XCTAssert(false, "Find no following decision")
                    return
                }
                let urlHasBeenChanged = request.baseURL == "https://unitest.RetryDecisionTests.url.1"
                XCTAssert(urlHasBeenChanged, "URL not change")
            case .errored(let error):
                print(error)
                XCTAssert(self.decision.retryCount == 0, "End of retry times")
            default:
                XCTAssert(false)
            }
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

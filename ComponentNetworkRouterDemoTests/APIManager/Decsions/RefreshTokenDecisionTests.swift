//
//  RefreshTokenDecisionTests.swift
//  ComponentNetworkRouterDemoTests
//
//  Created by 黃柏叡 on 2019/10/30.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import XCTest

class RefreshTokenDecisionTests: XCTestCase {

    var decision = RefreshTokenDecision()
    let req = UserRequestTest()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNilShouldApply() {
        
        let shouldApply = decision.shouldApply(request: req, data: nil, response: nil, error: nil)
        XCTAssertEqual(shouldApply, true)
    }
    
    func testErrorShouldApply() {
        
        let shouldApply = decision.shouldApply(request: req, data: nil, response: nil, error: nil)
        XCTAssertEqual(shouldApply, true)
    }
    
    func testApply() {
        decision.apply(request: req, data: nil, response: nil, error: nil, decisions: []) { (action) in
            switch action {
            case .restartWith(let request , let decisions):
                XCTAssert(true)
            default:
                XCTFail()
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

//
//  RouterTests.swift
//  ComponentNetworkRouterDemoTests
//
//  Created by 黃柏叡 on 2019/10/30.
//  Copyright © 2019 黃柏叡. All rights reserved.
//

import XCTest

class RouterTests: XCTestCase {
    
    let router = Router()

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let req = UserRequestTest()
        router.send(req) { (result) in
            print(result)
        }
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

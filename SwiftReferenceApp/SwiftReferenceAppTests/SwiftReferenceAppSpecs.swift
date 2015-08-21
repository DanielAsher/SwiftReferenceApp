//
//  SwiftReferenceAppTests.swift
//  SwiftReferenceAppTests
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import UIKit
import XCTest
import Nimble
import Quick
import SwiftTask
import SwiftyStateMachine
import RxSwift


class SwiftReferenceAppSpecs: QuickSpec {
    
    override func spec() {
        describe("Framework dependencies") 
        {
           it("loads SwiftTask") 
           {
                var str = "Started..."
                let task = Task<Void, String, Void> { p, f, r, c in
                    f("Finished!")
                }.success { value -> String in
                    str = value
                    return value
                }
                
                expect(str).toEventually(equal("Finished!"), timeout: 1)
            }
            
            it("loads SwiftyStateMachine") {
                
            }
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

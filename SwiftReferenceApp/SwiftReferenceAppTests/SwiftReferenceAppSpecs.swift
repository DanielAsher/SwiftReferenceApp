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
import SwiftReferenceApp


class SwiftReferenceAppSpecs: QuickSpec {
    
    override func spec() 
    {
        describe("Framework dependencies") 
        {
           it("loads SwiftTask") 
           {
                var str = "Started..."
                
                let task = Task<Void, String, Void> { p, fulfill, r, c in
                    
                    fulfill("Finished!")
                    
                }.success { value -> String in
                    str = value
                    return value }
                
                expect(str).toEventually(equal("Finished!"))
            }
            
            it("loads SwiftyStateMachine") 
            {
                let schema = StateMachineSchema<AppState, AppEvent, String>(initialState: AppState.Initial) 
                { state, event in
                    switch (state, event) 
                    {
                        case (.Initial, .Start): 
                            return (AppState.Idle, nil)
                        default: 
                            return nil
                    }
                }
                
                let machine = StateMachine(schema: schema, subject: "")
                
                machine.addDidTransitionCallback { oldState, event, newState, trace in println("\(oldState)  <- \(event) |-> \(newState)")
                }
                
                machine.handleEventAsync(AppEvent.Start, delay: 0.5)  
                
                expect ( machine.state ).toEventually ( equal ( AppState.Idle ))
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}

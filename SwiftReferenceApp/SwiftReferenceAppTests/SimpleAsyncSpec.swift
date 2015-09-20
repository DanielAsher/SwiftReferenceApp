//
//  SimpleAsyncSpec.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 26/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import Nimble
import Quick
import RxSwift

class AsyncSpec: QuickSpec 
{
    override func spec() 
    {
        describe("async") {
            
            let machineState = Variable("Initial")
            
            machineState.debug("machineState:").subscribeNext { _ in return }
            
            let createService = { (resultState: String) -> Disposable in
                
                machineState.value = "Awaiting"
                
                return interval(3.0, MainScheduler.sharedInstance) 
                    .take(1) // take only the next async `result`. 
                    // Here we ignore that and simply set to `modified`.
                    .debug("service:")                 
                    .subscribeNext { result in machineState.value = resultState } 
            }
            
            beforeSuite {
                
            }
            
            beforeEach { createService("Modified") }
            
            afterEach { machineState.value = "Idle" }
            
            it("should do some async operation") {
                
                expect(machineState.value).toEventually(beginWith("Modified"), timeout: 5)                
                
                createService("LocallyModified")
                
                expect(machineState.value).toEventually(beginWith("LocallyModified"), timeout: 5) 
            }
        }
    }
}


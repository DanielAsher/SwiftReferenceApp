//
//  StateMachineSpecs.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 23/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import UIKit
import XCTest
import Nimble
import Quick
import RxSwift
import SwiftReferenceApp

class StateMachineSpecs: QuickSpec 
{    
    override func spec() 
    {
        beforeSuite {
            app.hsmTransitionState >- subscribeNext { appEvent, appState, userState in
                println("\(appEvent)  -> \(appState) & \(userState)")
            } 
        }
        
        describe("App state") 
        {
            it("moves from Initial to Idle on app start") {
                expect(app.machine.state).toEventually(equal(AppState.Idle))
            }
            
            it("moves from Idle on Save to Saving then on Saved back to Idle") {
                app.machine.handleEvent(.Save)
                expect(app.machine.state).toEventually(equal(AppState.Saving(nil)))
                expect(app.machine.state).toEventually(equal(AppState.Idle))
            }
            
            it("Trial user moves App to Alerting on the sixth Saved") {
               let sixSavedEvents = app.appEvent 
                        >- filter { $0 == AppEvent.Saved }
                        >- take(6) // Possible to check the reverse
                                         // i.e. that 5 Saved events wouldn't move to Altering.
                
                let manicSavePresser = interval(0.1, MainScheduler.sharedInstance)
                    >- subscribeNext { tick in app[.Save] }
                    
               sixSavedEvents >- subscribeCompleted { 
                    manicSavePresser.dispose() } 
                    
               expect(app.machine.state).toEventually(equal(AppState.Alerting(nil)), timeout: 5  )
            }
        }
    }
} 
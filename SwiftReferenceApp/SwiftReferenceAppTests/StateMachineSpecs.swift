//
//  StateMachineSpecs.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 23/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.

import UIKit
import Nimble
import Quick
import RxSwift
import SwiftReferenceApp

class StateMachineSpecs: QuickSpec 
{    
    override func spec() 
    {
        let printer = beforeSuite { return app.transition >+ { println($0) } }
                
        let newApp = beforeEach { return App() }
        
        describe("App state machine") 
        {
            it("moves from Initial to Idle on app start") 
            {
                expect(app.state).toEventually(equal(AppState.Idle))
            }
            
            it("moves from Idle on Save to Saving then on Saved back to Idle") 
            {
                app <- .Save
                expect(app.state).toEventually(equal(AppState.Saving))
                expect(app.state).toEventually(equal(AppState.Idle))
            }
            
            fit("moves App to Alerting for Trial User on the sixth Saved then, on successful purchase enables Save") 
            {

                let sixthSaveTransition = AppTransition(
                        oldState: .Saving, event:.Failed, 
                        newState: .Alerting, userState: .Trial(count: 6)
                        )
                
                let buttonPusher = ticker(0.5) >+ { tick in app <- .Save }
                
                using( buttonPusher ) 
                {
                    expect(app.transition.value)
                    .toEventually(equal(sixthSaveTransition), timeout: 10, pollInterval: 1) 
                }
                 
                app.appState >- on(.Idle) { app <- .Purchase } 
                
                expect(app.user.machine.state).toEventually(equal(UserState.FullAccess), timeout: 2)
            }
            
            it("Trial user moves to FullAccess after Purchased and to Alerting if they attempt to Purchase again.") {
               
                expect(app.state).to(equal(AppState.Idle)) 
                
                app <- .Purchase
               
                app.appEvent >- on(.Purchased) 
                { 
                    expect(app.user.machine.state) .toEventually(equal(UserState.FullAccess))  
                    
                    app <- .Purchase
                }
                  
                expect(app.state).toEventually(equal(AppState.Alerting), timeout: 3)
                
                // Produces the following trace in the test log.
                // > AppState.Initial          -> Start          |-> AppState.Idle & Trial (count: 0)
                // > AppState.Idle             -> Purchase   |-> AppState.Purchasing & Trial (count: 0)
                // > AppState.Idle             -> Purchase   |-> AppState.Purchasing & FullAccess
                // > AppState.Purchasing  -> Purchased |-> AppState.Idle & FullAccess
                // > AppState.Purchasing  -> Failed        |-> AppState.Alerting & FullAccess
            }
        }
    }
} 


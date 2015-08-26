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
        beforeSuite {
            app.hsmTransitionState >- subscribeNext { oldState, appEvent, appState, userState in
                println("\(oldState) -> \(appEvent)  |-> \(appState) & \(userState)")
            } 
        }
                
        let greeting = 
            beforeSuite { 
                return "Hello"
            }
        
        let newApp = 
            beforeEach { 
                return App() 
            }
        
        describe("App state machine") 
        {
            it("moves from Initial to Idle on app start") 
            {
                // Testing function `beforeEach`
                expect( greeting.value ).toEventually( equal ("Hello") ) 
                greeting >- subscribeNext {
                    expect( $0 ).to(equal("Hello"))
                }
                
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

                let signalState = (AppState.Saving, AppEvent.Failed, AppState.Alerting, UserState.Trial(count: 6)) 
               
                let manicSavePresser = interval(0.8, MainScheduler.sharedInstance)
                    >- subscribeNext { tick in app <- .Save }

                expect(app.hsmTransitionState.value == signalState ).toEventually(beTrue(), timeout: 10, pollInterval: 1) 
                
                manicSavePresser.dispose()
                 
                app.appState >- on(.Idle) { app <- .Purchase }
                
                expect(app.userState.valueOrNil).toEventually(equal(UserState.FullAccess))
                
            }
            
            it("Trial user moves to FullAccess after Purchased and to Alerting if they attempt to Purchase again.") {
               
                expect(app.appState.valueOrNil).to(equal(AppState.Idle)) 
                
                app <- .Purchase
               
                app.appEvent >- takeOne(.Purchased) >- subscribeCompleted 
                { 
                    expect(app.userState.valueOrNil).toEventually(equal(UserState.FullAccess))  
                    app <- .Purchase
                }
                  
                expect(app.appState.valueOrNil).toEventually(equal(AppState.Alerting), timeout: 3)
                
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


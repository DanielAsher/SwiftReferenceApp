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
import RxBlocking
import SwiftReferenceApp

class StateMachineSpecs: QuickSpec 
{    
    override func spec() 
    {
        beforeSuite {
            app.hsmTransitionState >- subscribeNext { oldState, appEvent, appState, userState in
                println("\(oldState) <- \(appEvent)  |-> \(appState) & \(userState)")
            } 
        }
        
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
            
            it("moves App to Alerting for Trial User on the sixth Saved then, on successful purchase enables Save") 
            {
                
                var alertOnSixthSaveVariable = Variable(false)
                var successfulSaved = Variable(false)
            
                let a  = app.appEvent 
                    >- filter { $0 == AppEvent.Saved }
                               
                let manicSavePresser = interval(0.1, MainScheduler.sharedInstance)
                    >- subscribeNext { tick in app <- .Save }
                
                let alertOnSixthSave = app.hsmTransitionState
                    >- filter { o, event, a, u in switch (o, event, a, u) 
                        {
                        case (.Saving, .Failed, .Alerting, .Trial(let usageCount)): 
                            return usageCount == 6 
                                                 
                        case (_, .Saved, _, .Trial(let count)) where count > 5:
                            expect(event).toNot(equal(AppEvent.Saved))
                            return false
 
                        case (_, .Saved, _, _):
                            successfulSaved.next(true) 
                            return false
                                                                    
                        default: return false
                        }
                    } 
                    >- map { _ in return true } // Possible to use flatMap as filter/map ?
                    >- subscribeNext { 
                        alertOnSixthSaveVariable.next(true)  
                        manicSavePresser.dispose()
                        let appIdle = app.appState 
                            >- filter { $0 == AppState.Idle }
                            >- take(1)
                            >- subscribeNext { appState in app <- .Purchase }
                        }

                expect(alertOnSixthSaveVariable.value).toEventually( beTrue(), timeout: 10)
                expect( app.currentUser.state ).toEventually( equal ( UserState.FullAccess ), timeout: 10)   
                
                
                app <- .Save
                
                expect(successfulSaved.value).toEventually( beTrue(), timeout: 10 )
            }
            
            fit("Trial user moves to FullAccess after Purchased and to Alerting if they attempt to Purchase again.") {
               
               let purchased = app.appEvent 
                    >- filter {  $0 == .Purchased }
                    
                app.appState >- take(1) >- subscribeNext 
                    { expect($0).to(equal(AppState.Idle)) }
                
                app <- .Purchase
             
                // FIXME: Hangs the test runner!!
                //expect( (app.userState >- last).get() == UserState.FullAccess).to(beTrue()) 
                
                // TODO: Get into one-liner. Perhaps:
                // expect( app.userState ).toEventually(equal(UserState.FullAccess))
                let currentUserState = Variable(UserState.Trial(count: 0))
                app.userState >- subscribeNext { currentUserState.next($0) } 
                expect( currentUserState.value).toEventually(equal(UserState.FullAccess))  
                
                
            }
        }
    }
} 
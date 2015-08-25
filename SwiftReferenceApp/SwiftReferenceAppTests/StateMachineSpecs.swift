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
                // TODO: Refactor this monster !!
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
                expect( app.user.state ).toEventually( equal ( UserState.FullAccess ), timeout: 10)   
                
                app <- .Save
                
                expect(successfulSaved.value).toEventually( beTrue(), timeout: 10 )
            }
            
            fit("Trial user moves to FullAccess after Purchased and to Alerting if they attempt to Purchase again.") {
               
                expect(app.appState.value).to(equal(AppState.Idle)) 
                
                app <- .Purchase
               
                app.appEvent >- takeOne(.Purchased) >- subscribeCompleted 
                { 
                    expect(app.userState.value).toEventually(equal(UserState.FullAccess))  
                    app <- .Purchase
                }
                  
                expect(app.appState.value).toEventually(equal(AppState.Alerting), timeout: 3)
                
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
//extension Observable {
func takeOne<T: Equatable>(ofValue: T) -> Observable<T> -> Observable<T> {
    return { source in
        return source >- filter { $0 == ofValue } >- take(1) 
    }
}
//}

// Awaiting protocol extensions.
//extension Observable where Element is Equatable {
//    func takeOne<T: Equatable>(ofValue: Element) -> Observable<Element> {
//        return self //>- filter { $0 == ofValue } >- take(1) 
//    }
//}

//
//  App.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyStateMachine

enum AppState {
    case Initial
    case Idle
    case Saving(SaveDocument!)
    case Purchasing(PurchaseAccess!)
    case Alerting(AlertMessage!)
}

enum AppEvent {
    case Start
    case Complete
    case Failed
    case Purchase
    case Purchased
    case Save
    case Saved
}

class App 
{
    static let sharedInstance = App()

    let disposeBag = DisposeBag()
    var machine : StateMachine<Schema>! 
    var currentUser: User!
    var hsmTransitionState = Variable((AppEvent.Start, AppState.Initial, UserState.Trial(count: 0))) 
    var appState : Observable<AppState>
    var appEvent: Observable<AppEvent>
    var userState : Observable<UserState>
    
    private init() 
    {
        appState = self.hsmTransitionState >- map { (e, a, u) in return a }
        appEvent = self.hsmTransitionState >- map { (e, a, u) in return e }
        userState = self.hsmTransitionState >- map { (e, a, u) in return u }
        
        machine  = StateMachine(schema: App.schema, subject: self)
        
        machine.addDidTransitionCallback { o, event, newState, a in 
            let hsmState = (event, newState, self.currentUser.machine.state)
            self.hsmTransitionState.next(hsmState)
        }
    }
}


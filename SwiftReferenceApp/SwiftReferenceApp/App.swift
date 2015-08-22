//
//  App.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

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

    var currentUser: User!
    
    var machine : StateMachine<Schema>!
    
    var hsmTransitionState = Variable((AppEvent.Start, AppState.Initial, UserState.Trial(count: 0)))
     
    var appState : Observable<AppState>
    var appEvent: Observable<AppEvent>
    var userState : Observable<UserState>
    
    let disposeBag = DisposeBag()
    
    private init() 
    {
        appEvent = self.hsmTransitionState >- map { (e, a, u) in return e } // FIXME: these maps are inefficient
        appState = self.hsmTransitionState >- map { (e, a, u) in return a }
        userState = self.hsmTransitionState >- map { (e, a, u) in return u }
        
        machine  = StateMachine(schema: App.schema, subject: self)
        
        machine.addDidTransitionCallback { oldState, event, newState, app in 
            let hsmState = (event, newState, self.currentUser.machine.state)
            self.hsmTransitionState.next(hsmState)
        }
    }
}


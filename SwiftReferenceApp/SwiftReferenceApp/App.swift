//
//  App.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import RxSwift
import SwiftyStateMachine

public enum AppState {
    case Initial
    case Idle
    case Saving(SaveDocument!)
    case Purchasing(PurchaseAccess!)
    case Alerting(AlertMessage!)
}

public enum AppEvent {
    case Start
    case Complete
    case Failed
    case Purchase
    case Purchased
    case Save
    case Saved
}

public class App 
{
    public static let sharedInstance = App()

    public var currentUser: User!
    
    public var machine : StateMachine<Schema>!
    
    public var hsmTransitionState = Variable((AppEvent.Start, AppState.Initial, UserState.Trial(count: 0)))
     
    public var appState : Observable<AppState>
    public var appEvent: Observable<AppEvent>
    public var userState : Observable<UserState>
    
    public let disposeBag = DisposeBag()
    
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


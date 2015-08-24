//
//  App.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import RxSwift
import SwiftyStateMachine



public class App 
{
    public static let sharedInstance = App()

    public var currentUser: User!
    
    public var machine : StateMachine<Schema>!
    
    // FIXME: This initialization is incorrect and needs to read state from App.machine.
    private var _hsmTransitionState = 
        Variable((AppState.Initial, AppEvent.Start, AppState.Idle, UserState.Trial(count: 0))) 
    
    public lazy var hsmTransitionState : ReadOnlySubject<AppTransitionState> = {
        return self._hsmTransitionState >- readOnly 
    }()
     
    // TODO: Evaluate if appOldState is necessary
    //public var appOldState : Observable<AppState>
    public var appState : Observable<AppState>
    public var appEvent: Observable<AppEvent>
    public var userState : Observable<UserState>
    
    public let disposeBag = DisposeBag()
    
    private init() 
    {
        // TODO: Consider whether these maps are inefficient.

        // TODO: Evaluate if appOldState is necessary
        //appOldState = self._hsmTransitionState >- map { (oldState, event, n, u) in return oldState } 
        appEvent = self._hsmTransitionState      >- map { (o, event, n, u)            in return event }         
        appState = self._hsmTransitionState       >- map { (o, e, newState, u)      in return newState }
        userState = self._hsmTransitionState      >- map { (o, e, n, userState)      in return userState }
        
        // Create machine.
        machine  = StateMachine(schema: App.schema, subject: self)
        
        machine.addDidTransitionCallback { oldState, event, newState, app in 
            let hsmState = (oldState, event, newState, self.currentUser.machine.state)
            self._hsmTransitionState.next(hsmState)
        }
    }
}


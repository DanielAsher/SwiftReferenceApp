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

    public var user: User!
    
    public var machine : StateMachine<Schema>!
   
    static let initialTransition = AppTransition( oldState: .Initial, event: .Start, newState: .Idle, userState: .Trial(count: 0) ) 
      
    public var transition = Variable(initialTransition) 
    
    // FIXME: This initialization is incorrect and needs to read state from App.machine.
    private var _hsmTransitionState = 
        Variable((AppState.Initial, AppEvent.Start, AppState.Idle, UserState.Trial(count: 0))) 
    
//    public lazy var hsmTransitionState : ReadOnlySubject<AppTransitionState> = {
//        return self._hsmTransitionState >- readOnly 
//    }()
     
    public var appState : Observable<AppState>
    public var appEvent: Observable<AppEvent>
    public var userState : Observable<UserState>
    
    public let disposeBag = DisposeBag()
    
    public required init() 
    {
        user = User()
        
        // TODO: Consider whether these maps are inefficient.
//        appEvent = self._hsmTransitionState      >- map { (o, event, n, u)            in return event }         
//        appState = self._hsmTransitionState       >- map { (o, e, newState, u)      in return newState }
//        userState = self._hsmTransitionState      >- map { (o, e, n, userState)      in return userState }
        
        appEvent    = self.transition.map { t in return t.event }
        appState    = self.transition.map { t in return t.newState }
        userState   = self.transition.map { t in return t.userState }
        
        // Create machine.
        machine  = StateMachine(schema: App.schema, subject: self)
        
        machine.addDidTransitionCallback { oldState, event, newState, trace in 
//            let hsmState = (oldState, event, newState, self.user.machine.state)
            let appTransition = AppTransition( oldState: oldState, event:event, newState: newState, userState: self.user.machine.state ) 
            self.transition.sendNext(appTransition)
//            self._hsmTransitionState.next(hsmState)
        }
    }
}


//
//  User.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyStateMachine
import SwiftTask

enum UserState {
    case FullAccess
    case Trial(count: Int)
}

class User 
{
    typealias Schema = GraphableStateMachineSchema<UserState, AppEvent, User> 
    
    var machine : StateMachine<Schema>! 
    
    init() {
        machine  = StateMachine(schema: User.schema, subject: self)
    }
    
    func saveDocument() { println(__FUNCTION__) }
    func showAlert()        { println(__FUNCTION__) }
    
    // Helper functions
    func handleEvent(event: AppEvent) { 
        machine.handleEvent(event) 
    }
    
    subscript(event: AppEvent) -> Void {
        machine.handleEvent(event)
    }
    
    subscript(state: UserState) -> UserState {
        set { machine.state = state }
        get { return machine.state }
    }
}



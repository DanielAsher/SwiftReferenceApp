//
//  User.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import SwiftyStateMachine

public enum UserState 
{
    case FullAccess
    case Trial(count: Int)
}

public class User 
{
    typealias Schema = GraphableStateMachineSchema<UserState, AppEvent, User> 
    
    var machine : StateMachine<Schema>! 
    
    func hasApplicationAccess() -> Bool {
        switch machine.state {
        case .Trial(let saveCount) where saveCount > 5: return false
        default: return true
        }
    }
    
    public init() {
        machine  = StateMachine(schema: User.schema, subject: self)
    }
 
    public subscript(event: AppEvent) -> Void {
        machine.handleEvent(event)
    }
}



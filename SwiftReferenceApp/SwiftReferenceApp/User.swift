//
//  User.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import SwiftyStateMachine

enum UserState 
{
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
 
    subscript(event: AppEvent) -> Void {
        machine.handleEvent(event)
    }
}



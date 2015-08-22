//
//  User+Schema.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import SwiftyStateMachine

extension User 
{
    static var schema = Schema(initialState: .Trial(count: 0)) 
    { 
        state, event in switch state 
        {
        case UserState.Trial(let count): switch event {
            case AppEvent.Purchase:
                return (UserState.FullAccess, nil)
                
            case AppEvent.Save:
                return (UserState.Trial(count: count+1), nil)
                
            default: 
                return nil
            }
            
        case .FullAccess: switch event 
        {
            case .Save:
                return nil
                
            case .Purchase:
                return nil
                
            default: 
                return nil
            }
        }
    }
}
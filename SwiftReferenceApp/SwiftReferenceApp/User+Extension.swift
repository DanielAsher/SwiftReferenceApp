//
//  User+Extension.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import SwiftyStateMachine

extension UserState 
{
    func hasApplicationAccess() -> Bool {
        switch self {
            case .Trial(let saveCount) where saveCount > 5: return false
            default: return true
        }
    }
}

// MARK: UserState DOTLabelable extension
extension UserState: DOTLabelable 
{
    static var DOTLabelableItems: [UserState] 
    {
        return [.FullAccess, .Trial(count: 0)]
    }
    
    var DOTLabel: String {
        switch self {
        case .FullAccess: return "FullAccess"
        case .Trial(let count): return "Trial"
        }
    }
}

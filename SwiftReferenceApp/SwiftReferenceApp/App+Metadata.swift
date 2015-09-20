//
//  App+Metadata.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 24/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.

import SwiftyStateMachine

public enum AppState {
    case Initial
    case Idle
    case Saving
    case Purchasing
    case Alerting
}

//extension AppEvent: Equatable { } // FIXME: Causes swicftc seg fault!!!
public enum AppEvent  {
    case Start
    case Complete
    case Failed
    case Purchase
    case Purchased
    case Save
    case Saved
}

// MARK: AppState DOTLabelable extension
extension AppState: DOTLabelable {
    
    func isSaving() -> Bool {
        switch self {
        case .Saving: return true
        default: return false
        }
    }
    
    public static var DOTLabelableItems: [AppState] 
    {
        return [ .Idle, .Saving, .Purchasing, .Alerting]
    }
    
    public var DOTLabel: String {
        switch self {
        case .Initial: return "Initial"
        case .Idle: return "Idle"
        case .Saving: return "Saving"
        case .Purchasing: return "Purchasing"
        case .Alerting: return "Alerting"
        }
    }
}

// MARK: AppEvent DOTLabelable extension
extension AppEvent: DOTLabelable 
{
    public static var DOTLabelableItems: [AppEvent] 
    {
        return [.Complete, .Failed, .Purchase, .Purchased, .Save, .Saved]
    }
    
    public var DOTLabel: String {
        switch self {
        case .Start: return "Start"
        case .Complete: return "Complete"
        case .Failed: return "Failed"
        case .Purchase: return "Purchase"
        case .Purchased: return "Purchased"
        case .Save: return "Save"
        case .Saved: return "Saved"
        }
    }
}

// MARK: Add printable conformance
extension AppState : CustomStringConvertible {
    public var description: String { return self.DOTLabel }
}

extension AppState : CustomDebugStringConvertible {
    public var debugDescription: String { return "AppState.\(self.DOTLabel)" }
}

extension AppEvent : CustomStringConvertible {
    public var description: String { return self.DOTLabel }
}

extension AppEvent : CustomDebugStringConvertible {
    public var debugDescription: String { return "AppEvent.\(self.DOTLabel)" }
}


public typealias AppTransitionState = (AppState, AppEvent, AppState, UserState)

public struct AppTransition {
    public let oldState : AppState
    public let event : AppEvent
    public let newState : AppState
    public let userState : UserState
    
    public init(oldState: AppState, event: AppEvent, newState: AppState, userState: UserState) {
        self.oldState = oldState
        self.event = event
        self.newState = newState
        self.userState = userState
    }
}

extension AppTransition : Equatable {}
public func == (lhs: AppTransition, rhs: AppTransition) -> Bool {
    let o = lhs.oldState == rhs.oldState
    let e = lhs.event == rhs.event 
    let n = lhs.newState == rhs.newState 
    let u = lhs.userState == rhs.userState 
    return o && e && n && u
}

extension AppTransition : CustomStringConvertible {
    public var description: String {
        return "AppTransition(oldState:\(self.oldState), event: \(self.event), newState: \(self.newState), userState: \(self.userState)"
    }
}

extension AppTransition :CustomDebugStringConvertible {
    public var debugDescription : String {
        return  "AppTransition(oldState:\(self.oldState), event: \(self.event), newState: \(self.newState), userState: \(self.userState)" 
    }
}


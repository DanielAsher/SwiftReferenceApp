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
    case Saving(SaveDocument!)
    case Purchasing(PurchaseAccess!)
    case Alerting(AlertMessage!)
}

//extension AppEvent: Equatable { } // FIXME: Causes swicftc seg fault!!!
public enum AppEvent : Equatable {
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
        return [ .Idle, .Saving(nil), .Purchasing(nil), .Alerting(nil)]
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
extension AppState : Printable {
    public var description: String { return "AppState.\(self.DOTLabel)" }
}

extension AppEvent : Printable {
    public var description: String { return self.DOTLabel }
}
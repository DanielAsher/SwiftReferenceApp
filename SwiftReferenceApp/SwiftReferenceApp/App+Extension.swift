//
//  App+Extension.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import Foundation
import RxSwift
import SwiftTask
import SwiftyStateMachine

typealias SaveDocument = Task<Void, String, NSError>
typealias PurchaseAccess = Task<String, Bool, NSError> 
typealias AlertMessage = Task<String, Bool, NSError>

// MARK: AppState DOTLabelable extension
extension AppState: DOTLabelable {
    static var DOTLabelableItems: [AppState] {
        return [ .Idle, 
            .Saving(nil), 
            .Purchasing(nil), 
            .Alerting(nil)]
    }
    
    var DOTLabel: String {
        switch self {
        case .Idle: return "Idle"
        case .Saving: return "Saving"
        case .Purchasing: return "Purchasing"
        case .Alerting: return "Alerting"
        }
    }
}

// MARK: StoryCharacterState DOTLabelable extension
extension AppEvent: DOTLabelable {
    static var DOTLabelableItems: [AppEvent] {
        return [.Complete, .Failed, .Purchase, .Purchased, .Save, .Saved]
    }
    
    var DOTLabel: String {
        switch self {
        case .Complete: return "Complete"
        case .Failed: return "Failed"
        case .Purchase: return "Purchase "
        case .Purchased: return "Purchased"
        case .Save: return "Save"
        case .Saved: return "Saved"

        }
    }
}

extension App {
    
    // FIXME: Causing swiftc seg fault!
    //
    //    static func createSaveTask() -> SaveDocument {
    //        return SaveDocument(paused: true) { p, f, r, c in
    //            timer(dueTime: 0.5, MainScheduler.sharedInstance) 
    //                >- take(1)
    //                >- subscribeNext { a in f("Saved") }
    //        }  
    //    }
    //    
    //    static func createPurchaseTask() -> PurchaseAccess {
    //        return PurchaseAccess(paused: true) { p, f, r, c in
    //            timer(dueTime: 0.5, MainScheduler.sharedInstance) 
    //                >- take(1)
    //                >- subscribeNext { a in f(true) }        
    //        }
    //    }
    //    
    //    static func createAlertTask() -> AlertMessage {
    //        return AlertMessage(paused: true) { p, f, r, c in
    //            timer(dueTime: 0.5, MainScheduler.sharedInstance) 
    //                >- take(1)
    //                >- subscribeNext { a in f(true) }         
    //        }  
    //    }
}
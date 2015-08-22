//
//  App+Extension.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import RxSwift
import SwiftTask
import SwiftyStateMachine

typealias SaveDocument = Task<Void, String, NSError>
typealias PurchaseAccess = Task<String, Bool, NSError> 
typealias AlertMessage = Task<String, Bool, NSError>

extension App 
{
    func createSaveTask() -> SaveDocument 
    {
        return SaveDocument { p, fulfill, reject, c in
            timer(dueTime: 0.5, MainScheduler.sharedInstance) 
                >- subscribeNext { tick in 
                    if self.currentUser.machine.state.hasApplicationAccess() { fulfill("Saved") } // FIXME: Ugly. HSM needed!!
                    else { reject(NSError()) }
                }
                >- self.disposeBag.addDisposable // FIXME: Causes swiftc seg fault if removed!
        }  
    } 

    func createPurchaseTask() -> PurchaseAccess 
    {
        return PurchaseAccess { p, fulfill, reject, c in
            timer(dueTime: 1.0, MainScheduler.sharedInstance) 
                >- subscribeNext { a in 
                    if arc4random_uniform(2) > 0 { fulfill(true) } else { reject(NSError()) }  // FIXME: Ugly. HSM needed!!
                }        
                >- self.disposeBag.addDisposable // FIXME: Causes swiftc seg fault if removed!
        }
    }

    func createAlertTask() -> AlertMessage 
    {
        return AlertMessage { p, f, r, c in
            timer(dueTime: 1.0, MainScheduler.sharedInstance) 
                >- subscribeNext { a in f(true) }         
                >- self.disposeBag.addDisposable // FIXME: Causes swiftc seg fault if removed!
        }  
    }  

    // Helper functions
    func handleEvent(event: AppEvent) { 
        machine.handleEvent(event) 
    }

    subscript(event: AppEvent) -> Void {
        machine.handleEvent(event)
    }

    subscript(state: AppState) -> AppState 
    {
        set { machine.state = state }
        get { return machine.state }
    }
    
    func set(user: User) -> Bool 
    {
        currentUser = user
        
        machine.addDidTransitionCallback { oldState, event, newState, app in 
           self.currentUser[event] 
        }
        return true
    }
}

// MARK: AppState DOTLabelable extension
extension AppState: DOTLabelable {

    func isSaving() -> Bool {
        switch self {
        case .Saving: return true
        default: return false
        }
    }
    
    static var DOTLabelableItems: [AppState] 
    {
        return [ .Idle, .Saving(nil), .Purchasing(nil), .Alerting(nil)]
    }
    
    var DOTLabel: String {
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
    static var DOTLabelableItems: [AppEvent] 
    {
        return [.Complete, .Failed, .Purchase, .Purchased, .Save, .Saved]
    }
    
    var DOTLabel: String {
        switch self {
        case .Start: return "Start"
        case .Complete: return "Complete"
        case .Failed: return "Failed"
        case .Purchase: return "Purchase "
        case .Purchased: return "Purchased"
        case .Save: return "Save"
        case .Saved: return "Saved"

        }
    }
}




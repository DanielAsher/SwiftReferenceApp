//
//  App.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyStateMachine
import SwiftTask

enum AppState {
    case Initial
    case Idle
    case Saving(SaveDocument!)
    case Purchasing(PurchaseAccess!)
    case Alerting(AlertMessage!)
}

enum AppEvent {
    case Start
    case Complete
    case Failed
    case Purchase
    case Purchased
    case Save
    case Saved
}

class App 
{
    typealias Schema = GraphableStateMachineSchema<AppState, AppEvent, App> 
    
    static let sharedInstance = App()
    
    var machine : StateMachine<Schema>! 
    
    private init() {
        machine  = StateMachine(schema: App.schema, subject: self)
    }
    
    static var schema = Schema(initialState: .Idle) 
    {   
        state, event in switch state 
        {
        case AppState.Initial: switch event {
            case AppEvent.Start:
                return (AppState.Idle, nil)
            default:
                return nil
            }
        case AppState.Idle: switch event {
            case AppEvent.Save:
                return (AppState.Saving(nil), nil)
        //        let saver = App.createSaveTask()
        //        return (AppState.Saving(saver), { _ in 
        //            return nil })
            case AppEvent.Purchase:
                return (AppState.Purchasing(nil), nil)
        //        let purchase = App.createPurchaseTask()
        //        return (.Purchasing(purchase), nil) 
            default: return nil
            }
        case AppState.Saving(let saver): switch event {
            case AppEvent.Saved:
                return (AppState.Idle, nil)
            case AppEvent.Failed:
                return (AppState.Alerting(nil), nil)
        //        let alert = App.createAlertTask()
        //        return (.Alerting(alert), nil)
            default: return nil
            }
        case AppState.Purchasing(let purchaser): switch event {
            case AppEvent.Purchased: 
                return (AppState.Idle, nil)
            case AppEvent.Failed:
                return (AppState.Alerting(nil), nil)
            default: return nil
            }
            
        case .Alerting(let alert): switch event {
            case .Complete: 
                return (.Idle, nil)
            default: return nil
            }
        default: return nil
        }
    } 
    
    // Helper functions
    func handleEvent(event: AppEvent) { 
        machine.handleEvent(event) 
    }
}


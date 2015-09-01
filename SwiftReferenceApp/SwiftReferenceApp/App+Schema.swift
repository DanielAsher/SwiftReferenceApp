//
//  App+Schema.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.

import SwiftyStateMachine

extension App 
{    
    public typealias Schema = GraphableStateMachineSchema<AppState, AppEvent, App> 

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
                return (AppState.Saving, { app in 
                    let saver = app.createSaveTask()
                        .success { (str: String) -> String in 
                            app <- .Saved; return str 
                        }
                        .failure { errorInfo -> String in 
                            app <- .Failed; return "Error!" // FIXME: Unable to use $0  
                        } 
                    return .Saving })
                
            case AppEvent.Purchase:
                return (AppState.Purchasing, { app in 
                    let purchaser = app.createPurchaseTask()
                        .success { isSaved -> Bool in 
                            app <- .Purchased; return isSaved 
                        }
                        .failure { errorInfo -> Bool in 
                            app <- .Failed; return false 
                        } 
                    return .Purchasing})
                
            default: return nil
            }
        case AppState.Saving(let saver): switch event {
            case AppEvent.Saved:
                return (AppState.Idle, nil)
                
            case AppEvent.Failed:
                return (AppState.Alerting, { app in 
                    let alerter = app.createAlertTask()
                        .success { saved in 
                            app <- .Complete; return saved 
                        }
                        .failure { errorInfo -> Bool in 
                            app <- .Failed; return false 
                        } 
                    return .Alerting })
                
            default: return nil
            }
            
        case AppState.Purchasing(let purchaser): switch event {
            case AppEvent.Purchased: 
                return (AppState.Idle, nil)
                
            case AppEvent.Failed:
                return (AppState.Alerting, nil)
                
            default: return nil
                }
                
        case AppState.Alerting(let alert): switch event {
            case AppEvent.Complete: 
                return (.Idle, nil)
                
            default: return nil
            }
        default: return nil
        }
    } 
}
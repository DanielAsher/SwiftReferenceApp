//
//  App+Tasks.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 24/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import RxSwift
import SwiftTask

public typealias SaveDocument = Task<Void, String, String>
public typealias PurchaseAccess = Task<String, Bool, String> 
public typealias AlertMessage = Task<String, Bool, NSError>

enum Error : ErrorType { case Error(String) }

extension App 
{
    func createSaveTask() -> SaveDocument 
    {
        return SaveDocument { p, fulfill, reject, c in
            timer(0.5, scheduler: MainScheduler.sharedInstance).subscribeNext { tick in 
                    if self.user.hasApplicationAccess() { fulfill("Saved") } // FIXME: Ugly. HSM needed!!
                    else { reject("Error saving.") }
                }.scopedDispose
        }  
    } 
    
    func createPurchaseTask() -> PurchaseAccess 
    {
        return PurchaseAccess { p, fulfill, reject, c in
            timer(0.5, scheduler: MainScheduler.sharedInstance).subscribeNext { a in 
                    if arc4random_uniform(2) > 0 { 
                        fulfill(true) } else { 
                        reject("Error purchasing") }  // FIXME: Ugly. HSM needed!!
                }.scopedDispose       
        }
    }
   
    func createPurchase() -> Observable<String>
    {
        return timer(0.5, scheduler: MainScheduler.sharedInstance).take(1).map{ tick in 
            
                if arc4random_uniform(2) > 0 
                        { return "PurchaseToken: \(tick)" } 
                else  { throw Error.Error("Error purchasing") }
                } 
    }
      
    func createAlertTask() -> AlertMessage 
    {
        return AlertMessage { p, f, r, c in
            timer(1.0, scheduler: MainScheduler.sharedInstance)
            .subscribeNext { a in f(true) }.scopedDispose         
        }  
    }  
} 


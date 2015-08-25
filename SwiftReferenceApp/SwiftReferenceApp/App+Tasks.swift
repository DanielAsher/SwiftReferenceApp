//
//  App+Tasks.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 24/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import RxSwift
import SwiftTask

public typealias SaveDocument = Task<Void, String, NSError>
public typealias PurchaseAccess = Task<String, Bool, NSError> 
public typealias AlertMessage = Task<String, Bool, NSError>

extension App 
{
    func createSaveTask() -> SaveDocument 
    {
        return SaveDocument { p, fulfill, reject, c in
            timer(dueTime: 0.5, MainScheduler.sharedInstance) 
                >- subscribeNext { tick in 
                    if self.user.hasApplicationAccess() { fulfill("Saved") } // FIXME: Ugly. HSM needed!!
                    else { reject(NSError()) }
                }
                >- self.disposeBag.addDisposable // FIXME: Causes swiftc seg fault if removed!
        }  
    } 
    
    func createPurchaseTask() -> PurchaseAccess 
    {
        return PurchaseAccess { p, fulfill, reject, c in
            timer(dueTime: 0.5, MainScheduler.sharedInstance) 
                >- subscribeNext { a in 
                    if arc4random_uniform(2) > 0 { 
                        fulfill(true) } else { 
                        reject(NSError()) }  // FIXME: Ugly. HSM needed!!
                }        
                >- self.disposeBag.addDisposable // FIXME: Causes swiftc seg fault if removed!
        }
    }
   
    func createPurchase() -> Observable<String>
    {
        return timer(dueTime: 0.5, MainScheduler.sharedInstance)  
            >- take(1)
            >- mapOrDie { tick in 
            
                if arc4random_uniform(2) > 0 
                        { return .Success(RxBox("PurchaseToken: \(tick)")) } 
                else  { return .Failure(NSError()) }
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
} 


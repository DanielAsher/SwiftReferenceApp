//
//  Global.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyStateMachine

// .NET's `using` language construct in a two-line function!
public func using(disposable: Disposable, closure: () -> ()) 
{
    closure()
    disposable.dispose() 
}

extension GraphableStateMachineSchema 
{ 
    func saveSchema(path: String) -> String?
    { 
        do {
            try self.DOTDigraph.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
            return path
        } catch {
            return nil
        }
    }
}

public func toArray<T>(observable: Observable<T>) -> [T] {
    var array = [T]()
    observable.subscribeNext  { array.append($0)  }
    return array
}  

public func skip<E>(m: Int, take t: Int) -> Observable<E> -> Observable<E> 
{ 
    return  { source in
        return source.skip(m).take(t)
        }
}

// FIXME: needs more thought!
public func elementAt<E>(n: Int) -> Observable<E> -> Observable<E> 
{
    if n > 0 {
        return  { source in
            return source.skip(n).take(1) 
        } 
    }
    else {
        return  { source in
            return source.take(1)      
        }  
    }
} 

//public class ReadOnlySubject<Element> : Observable <Element>{
//
//    private let _subject: BehaviorSubject<Element> 
//    
//    public var value: Element { return _subject.value }
//    public var valueResult: RxResult<Element> { return _subject.valueResult }
//    
//    public var hasObservers: Bool { return _subject.hasObservers }
//   
//    public override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable { 
//            return _subject.subscribe(observer) 
//        }
//      
//    public init(subject: BehaviorSubject<Element>) {
//        _subject = subject
//    }
//}
//
//public func readOnly<E>(source:BehaviorSubject<E>) -> ReadOnlySubject<E> {
//    return ReadOnlySubject(subject: source)
//}

extension Observable {
    
    // stop flickering signal.
    func lastFor(dueTime: MainScheduler.TimeInterval) -> Observable<Element> {
        let delay = just(0).delaySubscription(dueTime, MainScheduler.sharedInstance)
        return combineLatest(delay, self) { $1 }
    }
    
}


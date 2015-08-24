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

extension GraphableStateMachineSchema 
{ 
    func saveSchema(path: String) -> String? 
    { 
        var err: NSError?
        if self.DOTDigraph.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding, error: &err) && err == nil
        {
            return path
        }
        else 
        {
            return nil
        }
    }
}

public func skip<E>(m: Int, take take_: Int) -> Observable<E> -> Observable<E> 
{ 
    return  { source in
        return source
            >- skip(m)
            >- take(take_)
        }
}

// FIXME: needs more thought!
public func elementAt<E>(n: Int) -> Observable<E> -> Observable<E> 
{
    if n > 0 {
        return  { source in
            return source >- skip(n) >- take(1) 
        } 
    }
    else {
        return  { source in
            return source >- take(1)      
        }  
    }
} 

public class ReadOnlySubject<Element> : Observable <Element>{

    private let _subject: BehaviorSubject<Element> 
    
    public var value: Element { return _subject.value }
    public var valueResult: RxResult<Element> { return _subject.valueResult }
    
    public var hasObservers: Bool { return _subject.hasObservers }
   
    public override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable { 
            return _subject.subscribe(observer) 
        }
      
    public init(subject: BehaviorSubject<Element>) {
        _subject = subject
    }
}

public func readOnly<E>(source:BehaviorSubject<E>) -> ReadOnlySubject<E> {
    return ReadOnlySubject(subject: source)
}



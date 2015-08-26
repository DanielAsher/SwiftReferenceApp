//
//  Test+Extensions.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 25/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.

import Nimble
import Quick
import RxSwift

extension Observable 
{
    var valueOrNil: Element? 
        {
            var element: Element?
            self >-  take(1) >- subscribeNext { element = $0 }
            return element
    }
}

//extension Observable { // waiting for protocol extensions.
func takeOne<T: Equatable>(ofValue: T) -> Observable<T> -> Observable<T> {
    return { source in
        return source >- filter { $0 == ofValue } >- take(1) 
    }
}

func on<T: Equatable>(element: T, closure: () -> Void) -> Observable<T> -> Disposable {
    return { source in 
        source >- filter { $0 == element } >- take(1) >- subscribeNext { value in closure() }
    }
}

// Awaiting protocol extensions.
//extension Observable where Element is Equatable {
//    func takeOne<T: Equatable>(ofValue: Element) -> Observable<Element> {
//        return self //>- filter { $0 == ofValue } >- take(1) 
//    }
//}

public func beforeSuite<T >(closure: () -> T) -> Variable<T?> {
    
    let result = Variable<T?>(nil)
        
    let untypedWrapperClosure = { () -> Void in
        let value = closure()
        result.next(value)
    }
    
    beforeSuite(untypedWrapperClosure)

    return result
}

public func beforeEach<T>(closure: () -> T) -> Variable<T?> {
    
    let result = Variable<T?>(nil)
    
    let untypedWrapperClosure = { () -> Void in
        let value = closure()
        result.next(value)
    }
    
    beforeEach(untypedWrapperClosure)
    
    return result
}

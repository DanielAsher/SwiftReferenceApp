//
//  Test+Extensions.swift
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 25/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.

import RxSwift

extension Observable 
{
    var value: Element? 
        {
            var _value: Element?
            self >- take(1) >- subscribeNext { _value = $0 }
            return _value
    }
}

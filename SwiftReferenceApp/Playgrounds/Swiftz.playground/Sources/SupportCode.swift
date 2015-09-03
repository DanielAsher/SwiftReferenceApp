//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to Swiftz.playground.
//

import Darwin

extension Int {
    public static func random() -> Int {
        return Int(arc4random())
    }
    
    public static func random(range: Range<Int>) -> Int {
        return Int(arc4random_uniform(UInt32(range.endIndex - range.startIndex))) + range.startIndex
    }
}

extension Double {
    public static func random() -> Double {
        return drand48()
    }
}

public func optional(str: String) -> String? {
    if Int.random(0...5) > 0 
    { return .Some(str) } else   
    { return .None } 
}
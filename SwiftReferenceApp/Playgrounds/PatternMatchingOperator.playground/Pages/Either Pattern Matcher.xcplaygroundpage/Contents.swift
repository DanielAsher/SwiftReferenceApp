/*: 
# PatternMatching.playground
## SwiftReferenceApp
### Created by Daniel Asher on 3/09/2015.
### Copyright (c) 2015 StoryShare. All rights reserved.
*/

import UIKit

var str = "Hello, playground"


enum Either {
    case Left, Right
}

extension Either : CustomStringConvertible {
    var description : String {
        switch self {
        case .Left: return "Left"
        case .Right: return "Right"
        }
    }
}

func ~=(pattern: String, value: Either) -> Bool {
    return pattern == value.description
}

let either : Either -> Bool = { either in
    switch either {
    case "Left": return true
    default: return false
    }
}


either

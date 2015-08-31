//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

enum Either {
    case Left, Right
}

extension Either : Printable {
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


either(Either.Left)

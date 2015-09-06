//: [Previous](@previous)

import Foundation
import UIKit

var str = "Hello, playground"

enum DivisionError: ErrorType {
    case ByZero
}

func divide(dividend: Double, by divisor: Double) throws -> Double {
    guard divisor != 0.0 else {
        throw DivisionError.ByZero
    }
    return dividend / divisor
}

func performOperation(operation: () throws -> Double) rethrows -> Double {
    return try operation()
}
func div(dividend: Double, by divisor: Double) -> Double {
    do {
        return try divide(dividend, by: divisor)
    } catch DivisionError.ByZero {
        print("Division by zero is not allowed.")
        let sgn = 1 - 2 * Double(signbit(dividend))
        return sgn * Double.infinity
    } 
    catch let error {
        print("Undefined error! \(error)")
        let sgn = 1 - 2 * Double(signbit(dividend))
        return sgn * Double.infinity    
    }
}

let a = div(-4, by: 1)
//: [Next](@next)

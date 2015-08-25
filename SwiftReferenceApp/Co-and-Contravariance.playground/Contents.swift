//: Playground - noun: a place where people can play

import UIKit
import RxSwift

let x = Variable(0)

let y = x >- filter { $0 > 5 }

extension Observable 
{
    var value: Element? 
    {
        var _value: Element?
        self >- take(1) >- subscribeNext { _value = $0 }
        return _value
    }
}

func expect<T>(@autoclosure(escaping) expression: () -> T?) -> T? {
    return expression() 
}

var str = "Hello, playground"

let expected = expect(str)

str = "Stateful mutation!"

let mutated = expect(str)

//let reactiveX = expect(x.value)

let xValue = expect( x.value )


let filteredSoNil = expect( y.value )

x.next(10)
//x.next(20)

let nowWehave10 = expect( y.value  )
let andAgain10 = expect(y.value)
//
//
////let a = reactiveY.verify(true, FailureMessage(stringValue: "Failure is success"))
//
//
//
//
//import XCPlayground
//import Nimble
//
//XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)

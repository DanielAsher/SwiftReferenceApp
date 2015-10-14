//: [Previous](@previous)

import RxSwift
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely(true)

let tick = interval(1, MainScheduler.sharedInstance).take(2)

tick.subscribe { ev in
    print(ev)
}

enum Error : ErrorType { case Error}


var str = "Hello, playground"

//: [Next](@next)

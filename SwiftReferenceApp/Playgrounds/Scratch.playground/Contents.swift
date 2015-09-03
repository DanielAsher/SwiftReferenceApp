//: Playground - noun: a place where people can play

import Cocoa
import Prelude

var str = "Hello, playground"



let objectLiteral = (greeting: "Hello", generate: { $0 + " World"} )

objectLiteral.generate(objectLiteral.greeting)


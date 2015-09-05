//: [Previous](@previous)

import Foundation

protocol ParserType {
    typealias Input : CollectionType
    typealias Tree
    typealias Function = (Input, Input.Index) throws -> (Tree, Input.Index)
    typealias Error : ErrorType
} 

enum ParserError : ErrorType {
    case Error
}

enum Parser<C: CollectionType, T> : ParserType {
    typealias Input = C
    typealias Tree = T
    typealias Error = ParserError
}

prefix func % <Input: CollectionType where Input.Generator.Element: Equatable>
    (literal: Input) 
        -> Parser<Input, Input>.Function 
{
    literal.count
    return { inp, index in
        return (literal, literal.startIndex) 
        }
}

extension String : CollectionType {
}

//extension String.Index {
//    func a() {
//        self.
//    }
//}

let helloParser = %"Hello"
let str = "Hello again"
let result = try! helloParser(str, str.startIndex)

print("> Complete :) ")

//: [Next](@next)

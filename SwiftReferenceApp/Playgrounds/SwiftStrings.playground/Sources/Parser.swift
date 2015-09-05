import Foundation


//infix operator >>- {  associativity left precedence 130 }

//public func >>- <C: CollectionType, T, U> (parser: Parser<C, T>.Function, f: T -> Parser<C, U>.Function) -> Parser<C, U>.Function {
//    return { input, index in parser(input, index).flatMap { f($0)(input, $1) } }
//}


prefix operator % { }

public prefix func %
    <C: CollectionType where C.Generator.Element : Equatable>
    (literal: C) 
    (collection: C, index: C.Index) throws -> (match: C, forwardIndex: C.Index)
{
    let n = (literal.startIndex..<literal.endIndex).count
    if collection.startsWith(literal) {
        return (literal, collection.startIndex.advancedBy(n, limit: collection.endIndex)) 
    } else {
        throw ParserError<C>.Error(message: "expected \(literal) at offset:\(index)", index: index)
    }
}

public enum ParserError<C: CollectionType> : ErrorType {
    case Error(message: String, index: C.Index)
}

public enum 𝐏 < C: CollectionType, Tree> {
    public typealias 𝒇 = (C, C.Index) throws -> Result
    public typealias Result = (Tree, C.Index)
}

extension String : CollectionType {}

public func parse <C: CollectionType, Tree> (parser: 𝐏 <C, Tree>.𝒇, input: C) -> Tree?
{
    do {
        let (result, _) = try parser(input, input.startIndex)
        return result
    } catch ParserError<C>.Error(let msg, let idx) {
        print("\(msg) \(idx)")
        return nil
    } 
    catch {
        print("Undefined Error!!!")
        return nil
    }
}



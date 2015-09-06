/*: 
# Parser combinators from scratch 
## Swiftz.playground
### SwiftReferenceApp
### Created by Daniel Asher on 5/08/2015.
### Copyright (c) 2015 StoryShare. All rights reserved.
*/
/*:
## let `𝐏` be a parser monad: `𝐏 <Input,Tree>`
## let `𝒇` be the parser computation:
## `𝒇 : (Input, Input.Index) throws -> (Tree, Input.Index)`
*/
public enum 𝐏 < Input: CollectionType, Tree> {
    public typealias 𝒇 = (Input, Input.Index) throws -> Result
    public typealias Result = (Tree, Input.Index)
}
/*: 
## `>>-` : The fundamental operator `bind`
*/
infix operator >>- {  associativity left precedence 130 }
/*: 
 ## Bind: 
 `>>-` defines `𝐏<I, *>.𝒇` as monadic
*/
public func >>- <I: CollectionType, T, U> 
(
    parser:          𝐏<I, T>.𝒇, 
    transform:  T -> 𝐏<I, U>.𝒇) -> 𝐏<I, U>.𝒇 
{
    return { input, index in 
        let (result, newIndex) = try parser(input, index) 
        return try transform(result)(input, newIndex)
    }
}
/*: 
 `pure` returns a parser which always ignores its input and produces a constant value.
*/
public func pure<I: CollectionType, T>(value: T) -> 𝐏<I, T>.𝒇 {
    return { _, index in (value, index) }
}
//: `apply` returns a parser which applies `f` to transform the output of `parser`.
//: notice how `f` is _injected_ into parser's monadic context.
public func <^> <I: CollectionType, T, U> (f: T -> U, parser: 𝐏<I, T>.𝒇) -> 𝐏<I, U>.𝒇 {
    return parser >>- { pure(f($0)) }
}
//: map is a curried form of ` <^> `, to be used with `|>`
public func map<I: CollectionType, T, U>(f: T -> U)(_ parser: 𝐏<I, T>.𝒇) -> 𝐏<I, U>.𝒇 {
    return f <^> parser
}
//: `ParserError`
public enum ParserError<Input: CollectionType> : ErrorType {
    case Error(message: String, index: Input.Index)
}
//: The type of trees to drop from the input.
public struct Ignore {
    public init() {}
}
//: Parser algebras need `OR` and `AND` operators to map over their domain.
//: ## Alternation:
//: `alternate` takes two parsers, `(lhs: T)` and `(rhs: U)` and produces a tuple `(T, U)` 
func alternate<Input: CollectionType, T, U> (leftParser: 𝐏<Input, T>.𝒇, _ rightParser: 𝐏<Input, U>.𝒇)
    (input: Input, index: Input.Index) throws -> 𝐏<Input, Either<T, U>>.Result
{
    do {
        let (result, newIndex) = try leftParser(input, index)
        return ( Either<T,U>.Left(result), newIndex )
    } 
    catch ParserError<Input>.Error(_, _) {
        do {
            let (result, newIndex) = try rightParser(input, index)   
            return ( Either<T,U>.Right(result), newIndex ) 
        } 
        catch ParserError<Input>.Error(let m, let i) {
            throw ParserError<Input>.Error(message: "no alternative matched: \(m)", index: i)
        }
    }
}
//: `|` parses either `(lhs: U)` or `(rhs: T)` and creates a parser that returns `Either<T, U>`
public func | <I: CollectionType, T, U> (lhs: 𝐏<I, T>.𝒇, rhs: 𝐏<I, U>.𝒇) -> 𝐏<I, Either<T, U>>.𝒇 {
    return alternate(lhs, rhs)
}
//: `|` parses either `(lhs: T)` or `(rhs: T)` and creates a parser that **coalesces** their `T`s
public func | <I: CollectionType, T> (lhs: 𝐏< I, T >.𝒇, rhs: 𝐏<I, T>.𝒇) -> 𝐏<I, T>.𝒇 {
    return alternate(lhs, rhs) 
        |> map { $0.either(onLeft: identity, onRight: identity) }
}
//: ## Concatenation:
//: Concatenation operator. 
//: `++` associates to the right, linked-list style. Higher precedence than `|.`
infix operator ++ { associativity right precedence 160 }
//: `++` parses the concatenation of `lhs` and `rhs`, pairing their parse trees in tuples of `(T, U)`
public func ++ <I: CollectionType, T, U> (
    lhs: 𝐏<I, T     >.𝒇, 
    rhs: 𝐏<I, U     >.𝒇) 
      -> 𝐏<I, (T, U)>.𝒇 
{
    return lhs >>- { x in { y in (x, y) } <^> rhs }
}
//: `++` parses the concatenation of `lhs` and `rhs`, dropping `rhs`’s parse tree to generate `T`
public func ++ <I: CollectionType, T> (
    lhs: 𝐏<I, T     >.𝒇, 
    rhs: 𝐏<I, Ignore>.𝒇) 
      -> 𝐏<I, T     >.𝒇 
{
    return lhs >>- { x in  const(x) <^> rhs }
}
//: Parses the concatenation of `lhs` and `rhs`, dropping `lhs`’s parse tree generating `T`
public func ++ <I: CollectionType, T> (
    lhs: 𝐏<I, Ignore>.𝒇, 
    rhs: 𝐏<I, T     >.𝒇) 
      -> 𝐏<I, T     >.𝒇 
{
    return lhs >>- const(rhs)
}
//: Helpers decrements `x` iff it is not equal to `Int.max`.
private func decrement(x: Int) -> Int {
    return (x == Int.max ? Int.max : x - 1)
}
private func decrement(x: ClosedInterval<Int>) -> ClosedInterval<Int> {
    return decrement(x.start)...decrement(x.end)
}
/*: 
# Repetition
 `*` is the cardinality combinator, taking a `𝐏<I, T>.𝒇` and producing `𝐏<I, [T]>.𝒇` 

An interval specifying the number of repetitions to perform 
* `0...n` means at most `n` repetitions; 
* `m...Int.max` means at least `m` repetitions; 
* and `m...n` means between `m` and `n` repetitions (inclusive).
*/
public func * <I: CollectionType, T> (parser: 𝐏<I, T>.𝒇, interval: ClosedInterval<Int>) -> 𝐏<I, [T]>.𝒇 
{
    if interval.end <= 0 { return { _, index in ([], index) } }
    
    let next = parser >>- { x in { [x] + $0 } <^> (parser * decrement(interval)) }
    
    let error : 𝐏<I, [T]>.𝒇 = 
        
        { input, index in
     
            if interval.start <= 0 { 
                return ([], index) 
            } else {
                throw ParserError<I>.Error(
                    message: "expected at least \(interval.start) matches", 
                    index: index) 
            }
        }
        
    return next | error	
}
/*: 
Parses `parser` the number of times specified in `interval`.
An `interval` specifys the number of repetitions to perform. 
* `0..<n` means at most `n-1` repetitions; 
* `m..<Int.max` means at least `m` repetitions; 
* and `m..<n` means at least `m` and fewer than `n` repetitions; 
* `n..<n` is an error.
*/
public func * 
    <I: CollectionType, T> 
    (parser:    𝐏<I, T>.𝒇, 
    interval:   HalfOpenInterval<Int>) 
             -> 𝐏<I, [T]>.𝒇 
{
    return interval.isEmpty ? { throw ParserError<I>.Error(
            message: "cannot parse an empty interval of repetitions", 
            index: $1) } 
    : parser * (interval.start...decrement(interval.end))
}
//: Parses `parser` 0 or more times.
public postfix func * <I: CollectionType, T> 
    (parser: 𝐏<I, T>.𝒇) 
          -> 𝐏<I, [T]>.𝒇 
{
    return parser * (0..<Int.max)
}

public postfix func * 
    (string: String) -> 𝐏<String, [String]>.𝒇 
{
    return %(string) * (0..<Int.max)
}
//: Creates a parser from `string`, and parses it 0 or more times.
public prefix func %
    <I: CollectionType where 
        I.Generator.Element : Equatable,
        I.SubSequence.Generator.Element : Equatable>
    (literal: I) 
    (collection: I, index: I.Index) throws -> (match: I, forwardIndex: I.Index)
{
    let literalRange = literal.startIndex ..< literal.endIndex
    
    let matchEnd = index.advancedBy(literalRange.count, limit: collection.endIndex)

    if collection[index ..< matchEnd].elementsEqual(literal[literalRange]) {
        return (literal, matchEnd) 
    } else {
        throw ParserError<I>.Error(message: "expected \(literal) at offset:\(index)", index: index)
    }
}

prefix operator % { }

extension String : CollectionType {}
//: Returns a parser which parses any character in `interval`.
public prefix func % <I: IntervalType where I.Bound == Character>
    (interval: I) -> 𝐏<String, String>.𝒇 
{
    return { input, index in
        if (index < input.endIndex && interval.contains(input[index])) {
            return (input, index.successor())
        } else {
            throw ParserError<String>.Error(
                message: "expected an element in interval \(interval)", 
                index: index) 
        }
    }
}
//: Map operator. Lower precedence than |.
infix operator --> { associativity left precedence 100 }
//: Returns a parser which maps parse trees into another type.
public func --> <I: CollectionType, T, U>(
    parser:    𝐏<I, T>.𝒇, 
    transform: (I, Range<I.Index>, T) -> U
          ) -> 𝐏<I, U>.𝒇 
{
    // TODO: Consider implementing with `map`. Broke compiler first time I tried :)
    return { 
        input, index in // (input: I, index: C.Index) -> (U, C.Index)
            let (result, newIndex) = try parser(input, index) 
            let transformedResult = transform(input, (index ..< newIndex), result)
            return (transformedResult,  newIndex)
    }
}
//: Ignores any parse trees produced by `parser`.
public func ignore<I: CollectionType, T>(parser: 𝐏<I, T>.𝒇) -> 𝐏<I, Ignore>.𝒇 {
    return parser --> const(Ignore())
}
//: `parse` function. takes a `parser` and `input` and produces a `Tree?`
public func parse <Input: CollectionType, Tree> (parser: 𝐏 <Input, Tree>.𝒇, input: Input) -> Tree?
{
    do {
        let (result, _) = try parser(input, input.startIndex)
        return result
    } catch ParserError<Input>.Error(let msg, let idx) {
        print("\(msg) \(idx)")
        return nil
    } 
    catch {
        print("Undefined Error!!!")
        return nil
    }
}
//: # Let's use our new parser combinators :)
//let helloParser     = %"Hello"
//let helloOrGoodbyeParser    = %"Hello" | %"Goodbye"
//let p2 = parse(%"Hello" | %"Goodbye",    input: "Hello, playground.")
//let p3 = parse(%"Hello" | %"Goodbye",    input: "Goodbye, playground")

//: Not working!!
let p4 = %"Hello" ++ %"."
let r4 = parse(p4, input: "Hello.")

func a() -> (String, String.Index) {
    
    let helloStr = "Hello."
    let simpleAndParser = %"Hello" ++ %"."
    do {
        let (output, nextIndex) = try simpleAndParser(helloStr, helloStr.startIndex)
        return ("\(output)", nextIndex)
    } catch ParserError<String>.Error(let msg, let idx) {
        return (msg, idx)
    } catch {
        print("Undefined Error")
        return ("Undefined Error", "Undefined Error".startIndex)
    }
}

let r7 = a()
//let r5 = parse(%"Hello" ++ %"."     ,    input: "Hello.")




//let lower   = %("a"..."z")
//let upper   = %("A"..."Z")
//let digit   = %("0"..."9")
//
//let whitespace = ignore( %" " | %"\t" | %"\n" )
//let spaces = whitespace*

//func token<C: CollectionType, T>(parser: 𝐏<I, T>.𝒇 ) -> 𝐏<I, T>.𝒇 {
//    return parser ++ spaces 
//}



//: Let's run the raw parser function on some input. It's output is (.0 "Hello", .1 5)
//let greetingString = "Hello, playground."
//let result = try (%"Hello")(collection: greetingString, index: greetingString.startIndex)
//: Here we use our parse method to control the I/O
//let p = parse(%"Hello" | %"Goodbye", input: "Goodbye, playground")


//: Scratch section
//Optional.Some(1).map(3*)

//: Goodbye for now...
print("Our run was successful! \n\n Goodbye for now...")




///// Returns a parser which maps parse results.
/////
///// This enables e.g. adding identifiers for error handling.
//public func --> <C: CollectionType, T, U> (parser: 𝐏<I, T>.𝒇, transform: 𝐏<I, T>.Result -> 𝐏<I, U>.Result) -> 𝐏<I, U>.𝒇 {
//    return parser >>> transform
//}



///// Ignores any parse trees produced by a parser which parses `string`.
//public func ignore(string: String) -> 𝐏<String, Ignore>.𝒇 {
//    return ignore(%string)
//}

//let whitespace = ignore( %" " | %"\t" | %"\n" )
//let spaces = whitespace*

//func token(parser: 𝐏<String, String>.𝒇 ) -> 𝐏<String, String>.𝒇 {
//    return parser ++ spaces 
//}

//let r4 = parse(lower, input: "t")

/// Parses either `left` or `right` and coalesces their trees.
//public func |||| <C: CollectionType, T> (lhs: 𝐏< I, T >.𝒇, rhs: 𝐏<I, T>.𝒇) -> 𝐏<I, T>.𝒇 {
//    // TODO: Use `>>-` binding here.
//    return { input, index in
//        let (result, index) = try alternate(leftParser: lhs, rightParser: rhs)(input: input, index: index)
//        return (result.either(onLeft: identity, onRight: identity), index)
//    }
//}
//infix operator |||| {}



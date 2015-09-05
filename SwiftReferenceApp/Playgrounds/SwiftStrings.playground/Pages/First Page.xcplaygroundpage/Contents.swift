/*: 
# Swiftz.playground : Parser from scratch
## SwiftReferenceApp
### Created by Daniel Asher on 28/08/2015.
### Copyright (c) 2015 StoryShare. All rights reserved.
*/

import Swiftz

func alternate<Input: CollectionType, T, U>
    (leftParser leftParser: 𝐏<Input, T>.𝒇, rightParser: 𝐏<Input, U>.𝒇)
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

infix operator >>- {  associativity left precedence 130 }
public func >>- <C: CollectionType, T, U> (parser: 𝐏<C, T>.𝒇, f: T -> 𝐏<C, U>.𝒇) -> 𝐏<C, U>.𝒇 {
    return { input, index in 
        let (result, newIndex) = try parser(input, index) //{ f($0)(input, $1) } }
        return try f(result)(input, newIndex)
    }
}

/// Returns a parser which always ignores its input and produces a constant value.
/// When combining parsers with `>>-`, allows constant values to be injected into the parser chain.
public func pure<C: CollectionType, T>(value: T) -> 𝐏<C, T>.𝒇 {
    return { _, index in (value, index) }
}

/// Returns a parser which applies `f` to transform the output of `parser`.
public func <^> <C: CollectionType, T, U> (f: T -> U, parser: 𝐏<C, T>.𝒇) -> 𝐏<C, U>.𝒇 {
    return parser >>- { pure(f($0)) }
}

/// Curried `<^>`. Returns a parser which applies `f` to transform the output of `parser`.
public func map<C: CollectionType, T, U>(f: T -> U)(_ parser: 𝐏<C, T>.𝒇) -> 𝐏<C, U>.𝒇 {
    return f <^> parser
}

/// Parses either `left` or `right`.
public func | <C: CollectionType, T, U> (lhs: 𝐏<C, T>.𝒇, rhs: 𝐏<C, U>.𝒇) -> 𝐏<C, Either<T, U>>.𝒇 {
    return alternate(leftParser: lhs, rightParser: rhs)
}

/// Parses either `left` or `right` and coalesces their trees.
public func | <C: CollectionType, T> (lhs: 𝐏< C, T >.𝒇, rhs: 𝐏<C, T>.𝒇) -> 𝐏<C, T>.𝒇 {
    return alternate(leftParser: lhs, rightParser: rhs) 
        |> map { $0.either(onLeft: identity, onRight: identity) }
}

/// Decrements `x` iff it is not equal to `Int.max`.
private func decrement(x: Int) -> Int {
    return (x == Int.max ? Int.max : x - 1)
}

private func decrement(x: ClosedInterval<Int>) -> ClosedInterval<Int> {
    return decrement(x.start)...decrement(x.end)
}

/// \param interval  An interval specifying the number of repetitions to perform. `0...n` means at most `n` repetitions; `m...Int.max` means at least `m` repetitions; and `m...n` means between `m` and `n` repetitions (inclusive).
public func * <C: CollectionType, T> (parser: 𝐏<C, T>.𝒇, interval: ClosedInterval<Int>) -> 𝐏<C, [T]>.𝒇 
{
    if interval.end <= 0 { return { _, index in ([], index) } }
    
    return 
        (parser >>- { x in { [x] + $0 } <^> (parser * decrement(interval)) })
        |	{   
                if interval.start <= 0 { return ([], $1) } 
                else {
                    throw ParserError<C>.Error(
                        message: "expected at least \(interval.start) matches", 
                        index: $1) 
                }
            }
}

/// Parses `parser` the number of times specified in `interval`.
///
/// \param interval  An interval specifying the number of repetitions to perform. `0..<n` means at most `n-1` repetitions; `m..<Int.max` means at least `m` repetitions; and `m..<n` means at least `m` and fewer than `n` repetitions; `n..<n` is an error.
public func * <C: CollectionType, T> (parser: 𝐏<C, T>.𝒇, interval: HalfOpenInterval<Int>) -> 𝐏<C, [T]>.𝒇 
{
    return interval.isEmpty ? { throw ParserError<C>.Error(
            message: "cannot parse an empty interval of repetitions", 
            index: $1) } 
    : parser * (interval.start...decrement(interval.end))
}

/// Parses `parser` 0 or more times.
public postfix func * <C: CollectionType, T> (parser: 𝐏<C, T>.𝒇) -> 𝐏<C, [T]>.𝒇 {
    return parser * (0..<Int.max)
}

/// Creates a parser from `string`, and parses it 0 or more times.
public postfix func * (string: String) -> 𝐏<String, [String]>.𝒇 {
    return %(string) * (0..<Int.max)
}


var greetingString = "Hello, playground."
var farewellString = "Goodbye, playground"

let helloParser = %"Hello"

let result = try helloParser(collection: greetingString, index: greetingString.startIndex)

let p = parse(helloParser, input: greetingString)

let goodbyeParser = %"Goodbye"

let helloOrGoodbyeParser = helloParser | goodbyeParser
//
let p2 = parse(helloOrGoodbyeParser, input: greetingString)
let p3 = parse(helloOrGoodbyeParser, input: farewellString)
Optional.Some(1).map(3*)

print(farewellString)

/// Returns a parser which parses any character in `interval`.
public prefix func %<I: IntervalType where I.Bound == Character>(interval: I) -> 𝐏<String, String>.𝒇 
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


let lower   = %("a"..."z")
let upper   = %("A"..."Z")
let digit   = %("0"..."9")

let r4 = parse(lower, input: "t")

/// Parses either `left` or `right` and coalesces their trees.
//public func |||| <C: CollectionType, T> (lhs: 𝐏< C, T >.𝒇, rhs: 𝐏<C, T>.𝒇) -> 𝐏<C, T>.𝒇 {
//    // TODO: Use `>>-` binding here.
//    return { input, index in
//        let (result, index) = try alternate(leftParser: lhs, rightParser: rhs)(input: input, index: index)
//        return (result.either(onLeft: identity, onRight: identity), index)
//    }
//}
//infix operator |||| {}



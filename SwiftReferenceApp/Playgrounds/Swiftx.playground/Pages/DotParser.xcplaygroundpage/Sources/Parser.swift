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
public func pure<I: CollectionType, T>
    (value: T) -> 𝐏<I, T>.𝒇 
{
    return { _, index in (value, index) }
}
//: `apply` returns a parser which applies `f` to transform the output of `parser`.
//: notice how `f` is _injected_ into parser's monadic context.
public func <^> <I: CollectionType, T, U> 
   (transform: T -> U, 
    parser:    𝐏<I, T>.𝒇) 
            -> 𝐏<I, U>.𝒇 
{
    return parser >>- { pure(transform($0)) }
}
//: map is a curried form of ` <^> `, to be used with `|>`
public func map<I: CollectionType, T, U>
    (transform: T -> U)
    (_ parser:  𝐏<I, T>.𝒇) 
             -> 𝐏<I, U>.𝒇 
{
    return transform <^> parser
}
//: `ParserError`
public enum ParserError<Input: CollectionType> : ErrorType {
    case Error(message: String, index: Input.Index)
}

//: # Optionality
//: The type of trees to drop from the input.
public struct Ignore {
    public init() {}
}
//: `|?` is the optionality operator.
postfix operator |? {}
//: `|?` parses T zero or one time to return T?
public postfix func |? <I: CollectionType, T> 
    (parser: 𝐏<I, T>.𝒇) 
          -> 𝐏<I, T?>.𝒇 
{
    return first <^> parser * (0...1)
}
//: `|?` parses T zero or one time to return an `Ignore`, dropping the parse tree.
public postfix func |? <I: CollectionType> 
    (parser: 𝐏<I, Ignore>.𝒇) 
          -> 𝐏<I, Ignore>.𝒇 
{
    return ignore(parser * (0...1))
}
//: Parser algebras need `OR` and `AND` operators to map over their domain.
//: ## Alternation:
//: `alternate` takes two parsers, `(lhs: T)` and `(rhs: U)` and produces a tuple `(T, U)` 
func alternate<Input: CollectionType, T, U> 
    ( leftParser:  𝐏<Input, T>.𝒇, 
    _ rightParser: 𝐏<Input, U>.𝒇)
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
public func | <I: CollectionType, T, U> (
    lhs: 𝐏<I, T>.𝒇, 
    rhs: 𝐏<I, U>.𝒇) 
      -> 𝐏<I, Either<T, U>>.𝒇 
{
    return alternate(lhs, rhs)
}
//: `|` parses either `(lhs: T)` or `(rhs: T)` and creates a parser that **coalesces** their `T`s
public func | <I: CollectionType, T> (
    lhs: 𝐏<I, T>.𝒇, 
    rhs: 𝐏<I, T>.𝒇) 
      -> 𝐏<I, T>.𝒇 
{
    return alternate(lhs, rhs) |> map { $0.either(onLeft: identity, onRight: identity) }
}
func first<I: CollectionType>(input: I) -> I.Generator.Element? {
    return input.first
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
    return lhs >>- { x in const(x) <^> rhs }
}
//: Parses the concatenation of `lhs` and `rhs`, dropping `lhs`’s parse tree generating `T`
public func ++ <I: CollectionType, T> (
    lhs: 𝐏<I, Ignore>.𝒇, 
    rhs: 𝐏<I, T     >.𝒇) 
      -> 𝐏<I, T     >.𝒇 
{
    return lhs >>- const(rhs)
}

infix operator +- { associativity right precedence 160 }
public func +- <I: CollectionType, T, U> (
    lhs: 𝐏<I, T     >.𝒇,
    rhs: 𝐏<I, U     >.𝒇)
      -> 𝐏<I, T     >.𝒇
{
    return lhs >>- { x in { y in x } <^> rhs }
}

public protocol Addable { func +(lhs: Self, rhs: Self) -> Self }
extension String : Addable {}
//infix operator +=+ { associativity right precedence 160}
public func ++ <I: CollectionType, T where T: Addable> (
    lhs: 𝐏<I, T >.𝒇,
    rhs: 𝐏<I, T >.𝒇)
      -> 𝐏<I, T >.𝒇 
{
    return lhs >>- { x in { y in x + y } <^> rhs }
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
public func * 
    <I: CollectionType, T>(
    parser:     𝐏<I, T >.𝒇, 
    interval:   ClosedInterval<Int>) 
             -> 𝐏<I,[T]>.𝒇 
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
    (parser:    𝐏<I, T >.𝒇, 
    interval:   HalfOpenInterval<Int>) 
             -> 𝐏<I,[T]>.𝒇 
{
    return interval.isEmpty ? { throw ParserError<I>.Error(
        message: "cannot parse an empty interval of repetitions", 
        index: $1) } 
        : parser * (interval.start...decrement(interval.end))
}
//: Parses `parser` 0 or more times.
public postfix func * <I: CollectionType, T> 
    (parser: 𝐏<I, T >.𝒇) 
          -> 𝐏<I,[T]>.𝒇 
{
    return parser * (0..<Int.max)
}

public postfix func * 
    (string: String) -> 𝐏<String, [String]>.𝒇 
{
    return %(string) * (0..<Int.max)
}
//: Parses `parser` 1 or more times.
public postfix func + <C: CollectionType, T> (parser: 𝐏<C, T>.𝒇) -> 𝐏<C,[T]>.𝒇 {
    return parser * (1..<Int.max)
}

//: Creates a parser from `string`, and parses it 1 or more times.
public postfix func + (string: String) -> 𝐏<String, [String]>.𝒇 {
    return %(string) * (1..<Int.max)
}

//: Parses `parser` 1 or more times and drops its parse trees.
public postfix func + <C: CollectionType> (parser: 𝐏<C, Ignore>.𝒇) -> 𝐏<C, Ignore>.𝒇 {
    return ignore(parser * (1..<Int.max))
}

//: Creates a parser from `string`, and parses it 0 or more times.
prefix operator % { }
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
        throw ParserError<I>.Error(message: "expected \"\(literal)\" at offset:\(index)", index: index)
    }
}
extension String : CollectionType {}
//: Returns a parser which parses any character in `interval`.
public prefix func % 
    <I: IntervalType where I.Bound == Character>
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
    transform: (I, Range<I.Index>, T) -> U) 
            -> 𝐏<I, U>.𝒇 
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
public func ignore<I: CollectionType, T>
   (parser: 𝐏<I, T>.𝒇) 
         -> 𝐏<I, Ignore>.𝒇 
{
    return parser --> const(Ignore())
}
//: Ignores any parse trees produced by a parser which parses `string`.
public func ignore(string: String) -> 𝐏<String, Ignore>.𝒇 {
    return ignore(%string)
}
//: `parse` function. takes a `parser` and `input` and produces a `Tree?`
public func parse <Input: CollectionType, Tree> (
    parser: 𝐏 <Input, Tree>.𝒇, 
    input:  Input) 
        -> (Tree?, String?)
{
    do {
        let (result, _) = try parser(input, input.startIndex)
        return (result, nil)
    } catch ParserError<Input>.Error(let msg, _) {
        //        print("\(msg) \(idx)")
        return (nil, msg)
    } 
    catch let error {
        return (nil, "Undefined Error! \(error)")
    }
}
//: End of Parser Combinators. Phew!

/*: 
# Swiftz.playground
## SwiftReferenceApp
### Created by Daniel Asher on 03/09/2015.
### Copyright (c) 2015 StoryShare. All rights reserved.
## Swiftz core operators:
    Functor       fmap:   <^> <A, B>(A -> B, a: F<A>) -> F<B>
    Applicative   apply:  <*> <A, B>(F<A -> B>, F<A>) -> F<B>
    Monad         bind:   >>- <A, B>(F<A>, A -> F<B>) -> F<B>
*/
//import Swiftz
import func Swiftz.<^>
import func Swiftz.<*>
import func Swiftz.>>-
import func Swiftz.curry
import func Swiftz.|>
import func Swiftz.* // Sections!
//: pop "Sam" and "Daniel" into the monad
let sam = optional("Sam")
let daniel = optional("Daniel")
//: lift `String -> String` into `F` using `<^>` and apply on `F<A: String>` to generate `F<B: String>` 
let greeting = 
    { "Hi \($0)!" } <^> sam 
//: use `Functor` `fmap` to lift `(Character) -> Character` over Optional
let toLower = 
    greeting?.fmap { $0.toLower } 

let longerGreeting1 = 
    { a in { b in 
    "Hello " + a + ", my name is " + b + ". Pleased to meet you" } } 
    <^> sam <*> daniel
//: use `curry<A, B, C>(f: (A, B) -> C) -> A -> B -> C`
let longerGreeting2 = curry 
    { "Hello " + $0 + ", my name is " + $1 + ". Pleased to meet you" } 
    <^> sam <*> daniel
/*: Different ways to create curried functions
    let multiply_a : Int -> Int -> Int = curry { $0 * $1 } 
    let multiply_b = curry { (a:Int, b) in a * b }
    let multiply_c = { (a:Int) in { b in (a * b) } }
    let multiply_d = { (a:Int) in (a*) } // Uses `import func Swiftz.*` from `Sections.swift`
*/

//: type-inference seems to flow backwards to allow swift to infer the correct `-` operator
let result = 
    curry { x, y in x-y } <^> [3, 4] <*> [1,2,3]

print(result)








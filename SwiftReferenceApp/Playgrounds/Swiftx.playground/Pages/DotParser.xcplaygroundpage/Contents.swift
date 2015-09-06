//: [Previous](@previous)

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
//: # Let's use our new parser combinators to create a parser.
let whitespace  = %" " | %"\t" | %"\n"
let spaces      = ignore(whitespace*)
//: Our `token` defines whitespace handling.
func token(parser: 𝐏<String, String>.𝒇 ) -> 𝐏<String, String>.𝒇 {
    return parser ++ spaces 
}
prefix operator £ {}
public prefix func £ (literal: String) -> 𝐏<String, String>.𝒇 {
    return %literal |> token
}
//: Literal Characters and Strings

let equal        = £"="     
let leftBracket  = £"["      
let rightBracket = £"]"     
let leftBrace    = £"{"     
let rightBrace   = £"}"     
let arrow        = £"->"    
let link         = £"--"    
let semicolon    = £";"     
let comma        = £","     
let quote        = £"\""    

let separator   = (%";" | %",") |> token
let sep1        = separator|? |> map { $0 ?? "" }
let sep         = separator|? |> ignore
let lower       = %("a"..."z")
let upper       = %("A"..."Z")
let digit       = %("0"..."9")
/*: 
## *ID*
1. Any string of alphabetic ([a-zA-Z\200-\377]) characters, underscores ('_') or digits ([0-9]), not beginning with a digit
2. a numeral [-]?(.[0-9]+ | [0-9]+(.[0-9]*)? )
3. any double-quoted string ("...") possibly containing escaped quotes ('")1
4. an HTML string (<...>).
> FIXME: This only partially implement case (1). Complete cases (2), (3) and (4)!
> The parser currently REJECTS any non-`id` strings in quotations and floating-point numbers!
> FIXME: Also rejects `{rank=same 0 0}` !
*/
let id = (lower | upper | digit | %"_")+
    |> map { $0.joinWithSeparator("") }
    |> token
/*:
## _id_stmt_ : ID '=' ID
*/
let id_equality = id ++ ignore(equal) ++ ignore(quote|?) ++ id|? ++ ignore(quote|?)
    |> map { Attribute(name: $0, value: $1 ?? "") }

let id_equality2 = id ++ ignore(equal) ++ ignore(quote|?) ++ id|? ++ ignore(quote|?)
//    |> map { Attribute(name: $0, value: $1 ?? "") }
    
let p1 = (id_equality ++ sep)*

/*:



## _a_list_ : id_stmt [ (';' | ',') ] [ _a_list_ ]
*/
//let a_list = 
//    fix { a_list in
//        return id_equality ++ ignore( sep|? ) ++ a_list* 
//            |> map { [$0] + $1.flatMap { $0 } }
//    }



















//: [Next](@next)

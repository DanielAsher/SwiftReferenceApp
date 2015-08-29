//
//  Parser.playground
//  SwiftReferenceApp
//
//  Created by Daniel Asher on 21/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.

import Prelude
import Either
import Madness
import RxSwift

extension Either {
    var result: String {
        return self.either(ifLeft: {"\($0)"}, ifRight: {"\($0)"})
    }
}

typealias AttrListFunc = Parser<String, String>.Function
typealias ALF = AttrListFunc

let digit = %("0"..."9")
let lower = %("a"..."z")
let upper = %("A"..."Z")
let underscore = "_"
let space = " "
let linefeed = "\n"
let leftBrace = "{"
let rightBrace = "}"
let arrow = "->"
let semicolon = ";"
let comma = ","
let equal = "="

let whitespace = ignore( %space | %linefeed )
let spaces = ignore(whitespace*)
let separator = (%semicolon | %comma)
let sep     = (separator|? ++ spaces) |> map { $0 ?? "" }

//: FIXME: This handles only the most trivial ID. Please fix me :)
//: * _ID_
//: * Any string of alphabetic ([a-zA-Z\200-\377]) characters, underscores ('_') or digits ([0-9]), not beginning with a digit
//: * a numeral [-]?(.[0-9]+ | [0-9]+(.[0-9]*)? )
//: * any double-quoted string ("...") possibly containing escaped quotes ('")1
//: * an HTML string (<...>).
let ID = (lower | upper | digit | %underscore)+ |> map { "".join($0) }
//: * _id_stmt_ : ID '=' ID
let id_stmt = ID ++ spaces ++ %equal ++ ignore(whitespace*) ++ ID ++ spaces
    |> map { (id1, rem) in "\(id1) \(rem.0) \(rem.1)" } // Render to string.
//: * _a_list_ : _id_stmt_ [ (';' | ',') ] [ _a_list_ ]
let a_list : ALF = fix { (a_list: ALF) -> ALF in

    return id_stmt ++ sep ++ a_list*
        |> map { (attr, rest) in "\(attr) \(rest.0) \(rest.1)" } // Render.
    }

let a_list_res = parse(a_list, "compound = true; fontcolor=coral3, a=b \n c =d").result
a_list_res == "compound = true ; [fontcolor = coral3 , [a = b  [c = d  []]]]"
//: * _attr_list_ : (graph | node | edge) _attr_list_



let node_id = ID

let token = whitespace+ ++ ID ++ spaces 

let digraph = %("digraph") ++ token 
    |> map { (graph, name) in "\(graph) \(name)" }
     
let node = token
let edge = node ++ %arrow ++ node 
    |> map { (source, dest) in "\(source) \(dest.0) \(dest.1)" }

let scope = ignore(%leftBrace) ++ (edge | token) ++ ignore(%rightBrace) ++ whitespace*

let dotParser = digraph ++ scope
let output = parse(dotParser, simpleGraphDotString)

if let result = output.right {
    "\(result)"
} else {
    let error = output.left?.description   
}






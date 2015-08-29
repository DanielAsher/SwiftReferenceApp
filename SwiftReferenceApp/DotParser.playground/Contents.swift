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
let spaces = whitespace+
let separator = (%semicolon | %comma)

let ID = (lower | upper | digit | %underscore)+ |> map { "".join($0) }

// ID '=' ID
let id_equal_id = ID ++ %equal ++ ID 
    |> map { (id1, rem) in "\(id1) \(rem.0) \(rem.1)" } // Render to string.

let node_id = ID

// TODO: Yikes! a recursive grammar rules. Can we `fix` it?
// a_list : ID '=' ID [ (';' | ',') ] [ a_list ]

typealias AttrListFunc = Parser<String, String>.Function
typealias ALF = AttrListFunc

let a_list : ALF = fix { (a_list: ALF) -> ALF in
    let a = ignore(whitespace*) ++ separator|? ++ ignore(whitespace*)
    return id_equal_id ++ separator* ++ a_list*
        |> map { (attr, rest) in "\(attr) \(rest.0) \(rest.1)" }
}

parse(a_list, "compound=true;fontcolor=coral3").result




let token = spaces ++ ID ++ spaces 

let digraph = %("digraph") ++ token 
    |> map { (graph, name) in "\(graph) \(name)" }
     
let node = token
let edge = node ++ %arrow ++ node 
    |> map { (source, dest) in "\(source) \(dest.0) \(dest.1)" }

let scope = ignore(%leftBrace) ++ (edge | token) ++ ignore(%rightBrace) ++ spaces*

let dotParser = digraph ++ scope
let output = parse(dotParser, simpleGraphDotString)

if let result = output.right {
    "\(result)"
} else {
    let error = output.left?.description   
}






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

let digit = %("0"..."9")
let lower = %("a"..."z")
let upper = %("A"..."Z")
let space = " "
let linefeed = "\n"
let leftBrace = "{"
let rightBrace = "}"
let arrow = "->"

let alphaNumeric = (lower | upper | digit)+ |> map { "".join($0) }
let whitespace = ignore( %space | %linefeed )
let spaces = whitespace+

let token = spaces ++ alphaNumeric ++ spaces 
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






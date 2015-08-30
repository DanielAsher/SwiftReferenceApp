/*: 
# DotParser.playground
## SwiftReferenceApp
### Created by Daniel Asher on 28/08/2015.
### Copyright (c) 2015 StoryShare. All rights reserved.
*/
//: Imports
import Prelude
import Either
import Madness
import RxSwift
//: Extensions
extension Either {
    var result: String {
        return self.either(ifLeft: {"\($0)"}, ifRight: {"\($0)"})
    }
}
//: Literal Characters and Strings
let space = " "
let underscore = "_"
let newline = "\n"
let tab = "\t"
let leftBrace = "{"
let rightBrace = "}"
let leftBracket = "["
let rightBracket = "]"
let arrow = "->"
let link = "--"
let semicolon = ";"
let comma = ","
let equal = "="
let digit = %("0"..."9")
let lower = %("a"..."z")
let upper = %("A"..."Z")
let digraph = %("digraph")
//: Whitespace, separators and edge operations.
let whitespace = ignore( %space | %tab | %newline )
let spaces = ignore(whitespace*)
let separator = (%semicolon | %comma)
let sep     = (separator|? ++ spaces) |> map { $0 ?? "" }
let edgeop  = (%arrow | %link)
/*: 
## *ID*
1. Any string of alphabetic ([a-zA-Z\200-\377]) characters, underscores ('_') or digits ([0-9]), not beginning with a digit
2. a numeral [-]?(.[0-9]+ | [0-9]+(.[0-9]*)? )
3. any double-quoted string ("...") possibly containing escaped quotes ('")1
4. an HTML string (<...>).
> FIXME: This only partially implement case (1). Complete cases (2), (3) and (4).
*/
let ID = (lower | upper | digit | %underscore)+ |> map { "".join($0) }
/*:
## _id_stmt_ : ID '=' ID
*/
let id_stmt = ID ++ spaces ++ %equal ++ ignore(whitespace*) ++ ID ++ spaces
    |> map { (id1, rem) in "\(id1) \(rem.0) \(rem.1)" } // Render to string.
/*:
## _a_list_ : id_stmt [ (';' | ',') ] [ _a_list_ ]
*/
let a_list : Parser<String, String>.Function = 
    fix { a_list in
        return id_stmt ++ sep ++ a_list*
        |> map { (id_stmt, sep) in "\(id_stmt) \(sep.0) \(sep.1)" } // Render.
    }

let input1 = "compound = true; fontcolor=coral3, a=b \n \t\t hello = world "
let output1 = parse(a_list, input1).result
output1 == "compound = true ; [fontcolor = coral3 , [a = b  [hello = world  []]]]"
/*: 
## _attr_list_ : '[' [ a_list ] ']' [ _attr_list_ ]
*/
let attr_list : Parser<String, String>.Function =
    fix { attr_list in
        return spaces ++ %leftBracket ++ spaces ++ a_list ++ spaces ++ %rightBracket ++ attr_list*
            |> map { (lbrac, list) in "\(lbrac) \(list.0) \(list.1)" } // Render.
    }

let input2 = "[ compound = true; fontcolor=coral3, a=b \n \t\t hello = world ]"
let output2 = parse(attr_list, input2).result
/*:
## _attr_stmt_ : ("graph" | "node" | "edge") attr_list
*/
let attr_stmt = (%("graph") | %("node") | %("edge")) ++ attr_list

let input3 = "graph " + input2
let output3 = parse(attr_stmt, input3).result
output3 == "(graph, [ compound = true ; [fontcolor = coral3 , [a = b  [hello = world  []]]] (], []))"
/*: 
## _node_id_     : ID [ port ]
> FIXME: implement _[ port ]_
*/
let node_id = ID
/*: 
## _node_stmt_	: node_id [ attr_list ]
*/
let node_stmt = node_id ++ spaces ++ attr_list*
let input4 = "StartNode [xlabel = Start]"
let output4 = parse(node_stmt, input4).result
output4 == "(StartNode, [[ xlabel = Start  [] (], [])])"
/*: 
## _edgeRHS_     : edgeop (node_id | subgraph) [ _edgeRHS_ ]
> FIXME: add subgraph here! 
*/
let edgeRHS : Parser<String, String>.Function =  fix { edgeRHS in
    return edgeop ++ spaces ++ node_id ++ ignore(whitespace*) //++ edgeRHS*
        |> map { (edgeop, rem) in "\(edgeop) \(rem)" }
    }
let input5 = "-> ReceiveNode "
let output5 = parse(edgeRHS, input5).result
/*: 
## _edge_stmt_ : (node_id | subgraph) edgeRHS [ attr_list ]
*/
let edge_stmt = node_id ++ spaces ++ edgeRHS ++ ignore(whitespace*) ++ attr_list*

let input6 = "PreviousState -> NextState [label = Trigger]"
let output6 = parse(edge_stmt, input6).result
output6 == "(PreviousState, (-> NextState, [[ label = Trigger  [] (], [])]))"

/*: 
## _stmt_list_	
* _stmt_list_   :       [ stmt [ ';' ] [ _stmt_list_ ] ]
* _stmt_        :       node_stmt |	edge_stmt | attr_stmt | ID '=' ID |	subgraph
* _subgraph_    :       [ "subgraph" [ ID ] ] '{' stmt_list '}'
> FIXME: Yikes! needs mutual recursion. Test! Also Render needs work.
*/
let stmt_list : Parser<String, String>.Function = 
    fix { stmt_list in
        let subgraph_id = %("subgraph") ++ ignore(whitespace*) ++ ID|? ++ ignore(whitespace*)
        let subgraph = subgraph_id ++ %("{") ++ ignore(whitespace*) ++ stmt_list ++ ignore(whitespace*) ++ %("}") 
            |> map { "\($0)" }  // Render.
        let stmt = node_stmt | edge_stmt | attr_stmt | id_stmt | subgraph
            |> map { "\($0)" }  // Render.
        let stmt_list = stmt ++ ignore(whitespace*) ++ (%(";"))|? ++ ignore(whitespace*) ++ stmt_list* 
            |> map { (stmt, rem) in "\(stmt) \(rem.0) \(rem.1)" }
        return stmt_list
        }
        
/*:
## _graph_ : [ "strict" ] ("graph" | "digraph") [ ID ] '{' stmt_list '}'
We can now define the root of our grammar, **graph**
*/
let graph_id = (%("strict"))|? ++ (%("graph") | %("digraph")) ++ ignore(whitespace*) ++ ID|? 

let graph = graph_id ++ spaces ++ %leftBrace ++ ignore(whitespace*) ++ stmt_list ++ ignore(whitespace*) ++ %rightBrace ++ spaces
/*:
## DotParser Tests
*/
println(simpleGraphDotString)
simpleGraphDotString == "digraph G { \n    Hello -> World \n}\n"

let graph_id_test_parser = graph_id ++ any* |> map { (a, b) in "\(a)" }
let output8 = parse(graph_id_test_parser, simpleGraphDotString).result
output8 == "(nil, (digraph, Optional(\"G\")))"

let output9 = parse(graph, simpleGraphDotString).result

output9 == "((nil, (digraph, Optional(\"G\"))), ({, (.Left(.Left(.Left(.Left((Hello, []))))) nil [], })))"






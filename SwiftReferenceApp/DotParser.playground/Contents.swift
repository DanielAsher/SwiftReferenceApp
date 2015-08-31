/*: 
# DotParser.playground
## SwiftReferenceApp
### Created by Daniel Asher on 28/08/2015.
### Copyright (c) 2015 StoryShare. All rights reserved.
An abstract syntax tree and parser for [The DOT Language](http://www.graphviz.org/content/dot-language)
To enable generation of the follow type of diagram.
![StateMachine](ApplicationSchema.png)
*/
//: Syntax Tree
typealias ID = String

struct Attribute {
    let name: String
    let value: String
}

enum TargetType : String {
    case Graph  = "graph"
    case Node   = "node"
    case Edge   = "edge"
}

enum EdgeOp : String {
    case Directed   = "->"
    case Undirected = "--"   
}

struct EdgeRHS {
    let edgeOp : EdgeOp
    let target : ID
}

enum Statement {
    case Node(id: ID, attributes: [Attribute])
//: FIXME: `Edge` doesn't support `Subgraph` source and target
    case Edge(source: ID, edgeRHS: [EdgeRHS], attributes: [Attribute])
    case Attr(target: TargetType, attributes: [Attribute])
    case Property(Attribute)
    case Subgraph(id: ID?, stmt_list: [Statement])
}
//: ## Root `Graph`
enum Graph {
    case Directed(id: String?, stmt_list: [Statement])
    case Undirected(id: String?, stmt_list: [Statement])
}

//: Printable `extensions`
extension Attribute : Printable {
    var description : String {
        return "\(name) = \(value)"
    }
}

extension TargetType : Printable {
    var description: String {
        return self.rawValue
    }
}

extension EdgeOp : Printable {
    var description : String {
        return self.rawValue
    }
}

extension EdgeRHS : Printable {
    var description: String {
        return "\(edgeOp.rawValue) \(target)"
    }
}

extension Statement : Printable {
    var description : String {
        switch self {
            case Node(let id, let xs): return "Node ( \(id), \(xs) )"
            case Edge(let src, let es, let xs): return "Edge ( \(src), \(es), \(xs)"
            case Attr(let tgt, let xs): return "Attr ( \(tgt), \(xs) )"
            case Property(let attribute): return "Property ( \(attribute) )"
            case Subgraph(let id, let stmts): return "Subgraph ( \(id), \(stmts) )"
        }
    }
}

extension Either {
    var result: String {
        return self.either(ifLeft: {"\($0)"}, ifRight: {"\($0)"})
    }
}
//: Whitespace, separators and edge operations.
let whitespace = ignore( %" " | %"\t" | %"\n" )
let spaces = whitespace*

typealias P = Parser<String, String>.Function

func token(parser: P ) -> P {
    return parser ++ spaces 
}
//: Literal Characters and Strings
let equal        = token ( %"=" )
let leftBracket  = token ( %"[" )
let rightBracket = token ( %"]" )
let leftBrace    = token ( %"{" )
let rightBrace   = token ( %"}" )
let arrow        = token ( %"->" )
let link         = token ( %"--" )
let semicolon    = token ( %";" )
let comma        = token ( %"," )

let separator = token (%";" | %",") 
let sep       = separator|? |> map { $0 ?? "" }
let edgeop    = token (%"->" | %"--") |> map { EdgeOp(rawValue: $0)! }

let lower   = %("a"..."z")
let upper   = %("A"..."Z")
let digit   = %("0"..."9")
/*: 
## *ID*
1. Any string of alphabetic ([a-zA-Z\200-\377]) characters, underscores ('_') or digits ([0-9]), not beginning with a digit
2. a numeral [-]?(.[0-9]+ | [0-9]+(.[0-9]*)? )
3. any double-quoted string ("...") possibly containing escaped quotes ('")1
4. an HTML string (<...>).
> FIXME: This only partially implement case (1). Complete cases (2), (3) and (4).
*/
let id = (lower | upper | digit | %"_")+
    |> map { "".join($0) }
    |> token
/*:
## _id_stmt_ : ID '=' ID
*/
let id_stmt = id ++ ignore(equal) ++ id ++ ignore(sep)
    |> map { Attribute(name: $0, value: $1) }
/*:
## _a_list_ : id_stmt [ (';' | ',') ] [ _a_list_ ]
*/
let a_list = 
    fix { a_list in
        return id_stmt*
    }
/*: 
## _attr_list_ : '[' [ a_list ] ']' [ _attr_list_ ]
*/
let attr_list = fix { attr_list in
    return ignore(leftBracket) ++ a_list ++ ignore(rightBracket) ++ attr_list*
        |> map { x, xs in return x + xs.flatMap { $0 } }
    }
/*:
## _attr_stmt_ : ("graph" | "node" | "edge") attr_list
*/
let attr_target = %("graph") | %("node") | %("edge")
    |> token
    |> map { TargetType(rawValue: $0)! }

let attr_stmt = attr_target ++ attr_list
    |> map { t, xs in 
        Statement.Attr(target: t, attributes: xs) }

/*: 
## _node_id_     : ID [ port ]
> FIXME: implement _[ port ]_
*/
let node_id = id
/*: 
## _node_stmt_	: node_id [ attr_list ]
*/
let node_stmt = node_id ++ attr_list*
    |> map { name, xs in Statement.Node(id: name, attributes: xs.flatMap { $0 } ) }
/*: 
## _edgeRHS_     : edgeop (node_id | subgraph) [ _edgeRHS_ ]
> FIXME: add subgraph here! 
*/
let edgeRHS : Parser<String, [EdgeRHS]>.Function = fix { edgeRHS in
    // TODO: Get rid of nested tuples and the maps they require to unfold them.
    let edgeSpec = edgeop ++ node_id    
        |> map { [EdgeRHS(edgeOp: $0, target: $1)] }
    return edgeSpec ++ edgeRHS*         
        |> map { $0 + $1.flatMap { $0 } }
    }
/*: 
## _edge_stmt_ : (node_id | subgraph) edgeRHS [ attr_list ]
*/
let opt_attr = attr_list|? |> map { $0 ?? [] }
let edge_stmt = node_id ++ edgeRHS ++ opt_attr
    |> map { (s, es) in Statement.Edge(source: s, edgeRHS: es.0, attributes: es.1) }
/*: 
## _stmt_list_	
* _stmt_list_   :       [ stmt [ ';' ] [ _stmt_list_ ] ]
* _stmt_        :       node_stmt |	edge_stmt | attr_stmt | ID '=' ID |	subgraph
* _subgraph_    :       [ "subgraph" [ ID ] ] '{' stmt_list '}'
> FIXME: Yikes! needs mutual recursion. Test! Also Render needs work.
*/
//let stmt_list : Parser<String, String>.Function = 
//    fix { stmt_list in
//        let subgraph_id = %("subgraph") ++ ignore(whitespace*) ++ id|? ++ ignore(whitespace*)
//        let subgraph = subgraph_id|? ++ %("{") ++ ignore(whitespace*) ++ stmt_list ++ ignore(whitespace*) ++ %("}") 
//            |> map { "\($0)" }  // Render.
//        let stmt = node_stmt | edge_stmt | attr_stmt | id_stmt | subgraph
//            |> map { "\($0)" }  // Render.
//        let stmt_list = stmt ++ ignore(whitespace*) ++ (%(";"))|? ++ ignore(whitespace*) ++ stmt_list* 
//            |> map { (stmt, rem) in "\(stmt) \(rem.0) \(rem.1)" }
//        return stmt_list
//        }
//        
/*:
## _graph_ : [ "strict" ] ("graph" | "digraph") [ ID ] '{' stmt_list '}'
We can now define the root of our grammar, **graph**
*/
//let graph_id = (%("strict"))|? ++ (%("graph") | %("digraph")) ++ ignore(whitespace*) ++ id|? 
//
//let graph = graph_id ++ spaces ++ %leftBrace ++ ignore(whitespace*) ++ stmt_list ++ ignore(whitespace*) ++ %rightBrace ++ spaces
/*:
## DotParser Tests
*/
let input1 = "compound = true; fontcolor=coral3, a=b \n \t\t hello = world "
let output1 = parse(a_list, input1).result
output1 == "[compound = true, fontcolor = coral3, a = b, hello = world]"

let input2 = "[ compound = true; fontcolor=coral3] [a=b \n \t\t hello = world ]"
let output2 = parse(attr_list, input2).result
output2 == "[compound = true, fontcolor = coral3, a = b, hello = world]"

let input3 = "graph " + input2
let output3 = parse(attr_stmt, input3).result
output3 == "Attr ( graph, [compound = true, fontcolor = coral3, a = b, hello = world] )"

let input4 = "StartNode [xlabel = Start]"
let output4 = parse(node_stmt, input4).result
output4 == "Node ( StartNode, [xlabel = Start] )"

let input5 = "-> ReceiveNode -> NextNode "
let output5 = parse(edgeRHS, input5).result
output5 == "[-> ReceiveNode, -> NextNode]"

let input6 = "SourceState -> TargetState [label = Trigger]"
let output6 = parse(edge_stmt, input6).result
output6 == "Edge ( SourceState, [-> TargetState], [label = Trigger]"

//println(simpleGraphDotString)
//simpleGraphDotString == "digraph G { \n    Hello -> World\n}\n"
//
//let graph_id_test_parser = graph_id ++ any* |> map { (a, b) in "\(a)" }
//let output8 = parse(graph_id_test_parser, simpleGraphDotString).result
//output8 == "(nil, (digraph, Optional(\"G\")))"
//
//let output9 = parse(graph, simpleGraphDotString).result
//
//output9 == "((nil, (digraph, Optional(\"G\"))), ({, (.Left(.Left(.Left(.Left((Hello, []))))) nil [], })))"


//: # Imports
import Prelude
import Either
import Madness
import RxSwift




/*: 
# DotParser.playground
## SwiftReferenceApp
### Created by Daniel Asher on 28/08/2015.
### Copyright (c) 2015 StoryShare. All rights reserved.
An abstract syntax tree and parser for [The DOT Language](http://www.graphviz.org/content/dot-language)
To enable generation of the follow type of diagram.
![StateMachine](ApplicationSchema.png)
*/
//: Imports
import Prelude
import Either
import Madness
import RxSwift
//: Syntax Tree Types
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
    case Edge(source: ID, edgeRHS: [EdgeRHS], attributes: [Attribute])
    case Attr(target: TargetType, attributes: [Attribute])
    case Property(Attribute)
    case Subgraph(id: ID?, stmts: [Statement])
}
//: ## Root `Graph`
enum GraphType : String {
    case Directed       = "digraph"
    case Undirected     = "graph"
}

struct Graph {
    let type        : GraphType
    let id          : String?
    let stmt_list   : [Statement]
}
//: Printable `extensions`

extension Statement {
    var toString : String {
        switch self {
        case let Node(id, attrs): 
            return "\(self)"
        case let Edge(source, edgeRHS, attributes):
            return "\(self)"
        case let Attr(target, attributes):
            return "\(self)"
        case let Property(attr):
            return "\(self)"
        case let Subgraph(id, stmts):
            return "\(self)"
         }
    }
}

extension Graph {
    var toString : String {
        let id = self.id ?? ""
        let stmts_render = self.stmt_list.reduce("") 
        { str, stmt -> String in
            return str + stmt.toString
        }
        return "\(type) \(id) { \(stmts_render) }"
    }
}

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
            case Node(let id, let xs): return "Node ( \(id), \(xs) )\n"
            case Edge(let src, let es, let xs): return "Edge ( \(src), \(es), \(xs) )\n"
            case Attr(let tgt, let xs): return "Attr ( \(tgt), \(xs) )\n"
            case Property(let attribute): return "Property ( \(attribute) )\n"
            case Subgraph(let id, let stmts):
                return "Subgraph ( id: \"" + (id ?? "") + "\", stmts: \(stmts))"
        }
    }
}

typealias StatementsParser = Parser<String, [Statement]>.Function

extension GraphType : Printable {
    var description : String {
        return self.rawValue
    }
}

extension Graph : Printable {
    var description : String {
        let idstr = self.id ?? ""
        return "Graph ( type: \"\(self.type)\", id: \"\(idstr)\", stmt_list: \n\t\(self.stmt_list) )"
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
let quote        = token ( %"\"" )

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
> FIXME: This only partially implement case (1). Complete cases (2), (3) and (4)!
> The parser currently REJECTS any non-`id` strings in quotations and floating-point numbers!
> FIXME: Also rejects `{rank=same 0 0}` !
*/
let id = (lower | upper | digit | %"_")+
    |> map { "".join($0) }
    |> token
/*:
## _id_stmt_ : ID '=' ID
*/
let id_equality = id ++ ignore(equal) ++ ignore(quote|?) ++ id|? ++ ignore(quote|?)
    |> map { Attribute(name: $0, value: $1 ?? "") }
/*:
## _a_list_ : id_stmt [ (';' | ',') ] [ _a_list_ ]
*/
let a_list = 
    fix { a_list in
        return id_equality ++ ignore( sep|? ) ++ a_list* 
            |> map { [$0] + $1.flatMap { $0 } }
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
    |> map { t, xs in Statement.Attr(target: t, attributes: xs) }
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
    let edgeSpec = edgeop ++ node_id    |> map { EdgeRHS(edgeOp: $0, target: $1) }
    return edgeSpec ++ edgeRHS*         |> map { [$0] + $1.flatMap { $0 } }
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
let stmt_list : StatementsParser = fix { stmt_list in

    let id_stmt = id_equality |> map { Statement.Property($0) }
    
    let subgraph_id = token (%("subgraph")) ++ id|? |> map { $1 }

    let subgraph = subgraph_id ++ ignore(leftBrace) ++ stmt_list ++ ignore(rightBrace) 
        |> map { Statement.Subgraph(id: $0, stmts: $1) }
    
    // TODO: Figure out if the ordering of alternatives is essential
    let stmt = id_stmt | edge_stmt | attr_stmt | subgraph | node_stmt 

    return stmt ++ ignore( semicolon|? ) ++ stmt_list*
        |> map { x, xs in [x] + xs.flatMap { $0 } }
    }
/*:
## _graph_ : [ "strict" ] ("graph" | "digraph") [ ID ] '{' stmt_list '}'
We can now define the root of our grammar, **graph**
*/
//: FIXME: `let strict = token ( (%("strict"))|? )`

let graph_type = 
     ( %("graph") | %("digraph") ) 
        |> token
        |> map { GraphType(rawValue: $0)! }

let graph_id = graph_type ++ id|?

let graph = graph_id ++ ignore(leftBrace) ++ stmt_list ++ ignore(rightBrace)
    |> map { id, ss in Graph(type: id.0, id: id.1, stmt_list: ss) }
/*:
## DotParser Tests
*/


let output = parse(graph, simpleGraphDotString)
let result = output.right!

println(result.toString)

typealias Renderer = Parser<[Statement], String>.Function
//(C, C.Index) -> Either.Either<Madness.Error<C.Index>, (Tree, C.Index)
let renderParser : Renderer = {
    stmts, index in
    return Either.left(Error.leaf("Unimplemented", index))
}
let stmts = result.stmt_list

//let render



//println(output.result)

//
//let input1 = "compound = true; fontcolor=coral3, a=b \n \t\t hello = world "
//let output1 = parse(a_list, input1).result
//output1 == "[compound = true, fontcolor = coral3, a = b, hello = world]"
//
//let input2 = "[ compound = true; fontcolor=coral3] [a=b \n \t\t hello = world ]"
//let output2 = parse(attr_list, input2).result
//output2 == "[compound = true, fontcolor = coral3, a = b, hello = world]"
//
//let input3 = "graph " + input2
//let output3 = parse(attr_stmt, input3).result
//output3 == "Attr ( graph, [compound = true, fontcolor = coral3, a = b, hello = world] )\n"
//
//let input4 = "StartNode [xlabel = Start]"
//let output4 = parse(node_stmt, input4).result
//output4 == "Node ( StartNode, [xlabel = Start] )\n"
//
//let input5 = "-> ReceiveNode -> NextNode "
//let output5 = parse(edgeRHS, input5).result
//output5 == "[-> ReceiveNode, -> NextNode]"
//
//let input6 = "SourceState -> TargetState [label = Trigger]"
//let output6 = parse(edge_stmt, input6).result
//output6 == "Edge ( SourceState, [-> TargetState], [label = Trigger] )\n"



 

/*: 
# Parser combinators from scratch 
## Swiftz.playground
### SwiftReferenceApp
### Created by Daniel Asher on 5/08/2015.
### Copyright (c) 2015 StoryShare. All rights reserved.
*/
//: Syntax Tree Types
public typealias ID = String

public struct Attribute {
    public let name: String
    public let value: String
    
    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

public enum TargetType : String {
    case Graph  = "graph"
    case Node   = "node"
    case Edge   = "edge"
}

public enum EdgeOp : String {
    case Directed   = "->"
    case Undirected = "--"   
}

public struct EdgeRHS {
    let edgeOp : EdgeOp
    let target : ID
}

public enum Statement {
    case Node(id: ID, attributes: [Attribute])
    case Edge(source: ID, edgeRHS: [EdgeRHS], attributes: [Attribute])
    case Attr(target: TargetType, attributes: [Attribute])
    case Property(Attribute)
    case Subgraph(id: ID?, stmts: [Statement])
}
//: ## Root `Graph`
public enum GraphType : String {
    case Directed       = "digraph"
    case Undirected     = "graph"
}

public struct Graph {
    let type        : GraphType
    let id          : String?
    let stmt_list   : [Statement]
}
//: Printable `extensions`

extension Statement {
    public var toString : String {
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
    public var toString : String {
        let id = self.id ?? ""
        let stmts_render = self.stmt_list.reduce("") 
            { str, stmt -> String in
                return str + stmt.toString
        }
        return "\(type) \(id) { \(stmts_render) }"
    }
}

extension Attribute : CustomStringConvertible {
    public var description : String {
        return "\(name) = \(value)"
    }
}

extension TargetType : CustomStringConvertible {
    public var description: String {
        return self.rawValue
    }
}

extension EdgeOp : CustomStringConvertible {
    public var description : String {
        return self.rawValue
    }
}

extension EdgeRHS : CustomStringConvertible {
    public var description: String {
        return "\(edgeOp.rawValue) \(target)"
    }
}

extension Statement : CustomStringConvertible {
    public var description : String {
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

//typealias StatementsParser = Parser<String, [Statement]>.Function

extension GraphType : CustomStringConvertible {
    public var description : String {
        return self.rawValue
    }
}

extension Graph : CustomStringConvertible {
    public var description : String {
        let idstr = self.id ?? ""
        return "Graph ( type: \"\(self.type)\", id: \"\(idstr)\", stmt_list: \n\t\(self.stmt_list) )"
    }
}

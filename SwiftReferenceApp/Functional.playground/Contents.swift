//: [De Bruijn index](http://en.wikipedia.org/wiki/De_Bruijn_index) ![De Bruijn index](http://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/De_Bruijn_index_illustration_1.svg/416px-De_Bruijn_index_illustration_1.svg.png)
var str = "Hello, playground"

//: The term λx. λy. x, sometimes called the _K combinator_, is written as λ λ 2 with De Bruijn indices. The binder for the occurrence x is the second λ in scope.

func K₁<A, B>() -> A -> B -> A { return { x in { y in x } } }
//func K₂<A, B>() -> A -> B -> A { { x in { $0 } } }

struct K<A, B> {
    let k : A -> B -> A = { x in { y in x } }
}

let b = K<Int, Int>()
let c = b.k(1)(2)
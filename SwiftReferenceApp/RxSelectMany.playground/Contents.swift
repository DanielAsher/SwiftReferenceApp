//
//  Created by Daniel Asher on 27/08/2015.
//  Copyright (c) 2015 StoryShare. All rights reserved.

import RxSwift
import RxBlocking
import XCPlayground

//XCPSetExecutionShouldContinueIndefinitely(continueIndefinitely: true)


infix operator >+ { associativity left precedence 90 }

func >+ <T>(lhs: Observable<T>, rhs: T -> ()) -> Disposable {
    return lhs >- subscribeNext { value in rhs(value) }
}

func toArray<T>(observable: Observable<T>) -> [T] {
//    return observable >- 
    var array = [T]()
    observable >+  { array.append($0)  }
    return array
} 


func toArray2<E>(observable: Observable<E>) -> [E] {
    return (observable 
    >- reduce( [E]() ) { (var arr, e) in
        arr.append(e)
        return arr
    } >- last).get()!
} 

var count = 0
func example<T>(of message: String, closure: () -> T) -> T  {
    let sentences = 
        from(message.componentsSeparatedByString("."))
    sentences  >- take(1) >+ 
        { v in println("Ex \(count++): \(v).") }
    sentences >- skip(1) >- take(1) >+ 
        { v in println("\t \(v)") }
    
    let result = closure() 
    println("")
    return result 
}

let seq = example(of: "Generating a sequence `seq` using a range.") 
{
   return from(1...3)  
}

example(of: "Subscribe and calculate (x, x²)") 
{
    seq >+ { x in 
        let y = x * x 
        println("\t(x, y) = \(x, y)") }
}
    
let seqOfSeq = example(of: "Generating a sequence of sequences.") 
{
    seq >- map 
                { i -> Observable<Int> in  
    if i <= 3  { return from(1...i) }
            else { return empty() }
    }
}

example (of: "Unfolding the sequences, commas wrong here. • How can we fix it?") { _ -> Void in
    print("\n\tseqOfSeq = ")
    seqOfSeq >+  { seq in
        print("{")
        seq >+  { x in 
            x; print("\(x),")
            }
        print("}")
        }
    println()
}


let flatMapped : Observable<Int> = 
    example(of: "flatMap using take(1) and skip(1)") 
    { 
        let  xs = seqOfSeq >- flatMap {$0 } 
        print("\t[")
        xs >- take(1) >+ { x in print(x) }
        xs >- skip(1) >+  { x in print(", \(x)") } 
        println("]")
        let a = Array(arrayLiteral: xs)
        return xs
    }


let concatSeq = example(of: "concatenation of a `seq` of `seq`") { 
//    let 
    return seqOfSeq >- concat
//    println(s >- toArray)
//   return s
}

 
func timedConcat() 
{
    let timedSeq =
        interval(1.0, MainScheduler.sharedInstance)
        >- take(6)
        >- map { a in 
            return a
            }
    timedSeq >- subscribeNext { x in
        x
        println(x)
    }
}

//timedConcat()






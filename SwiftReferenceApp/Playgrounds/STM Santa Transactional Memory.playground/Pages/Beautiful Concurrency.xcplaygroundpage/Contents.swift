//: Beautiful concurrency

//: http://research.microsoft.com/pubs/77415/TheEssenceOfDataAccessInCw(ECOOP2005).pdf
//: https://www.fpcomplete.com/school/advanced-haskell/beautiful-concurrency/4-the-santa-claus-problem

import Swiftz
import RxSwift

struct IO<T> {
    let val : T
    static var void : IO<()> { return IO<()>(val: ()) }
}

struct Gate {
    let maxCapacity : Int
    var capacity : Int
    let open : Variable<Bool> = Variable<Bool>(false)
    init(n: Int) {
        self.maxCapacity = n
        self.capacity = maxCapacity
    }
    func pass() -> Void {
    }
    mutating func operate() -> IO<()> {
        self.capacity = maxCapacity
        return IO<()>.void
    }
}

struct Group {
    let maxSize : Int
    func joinGroup() -> (entry: Gate, exit: Gate) {
        return (Gate(n: 0), Gate(n: 0))
    }
}
typealias Action = Void -> Void

let helper1 : Group -> Action -> Void = { g in { closure in 
        let gates = g.joinGroup()
        gates.entry.pass()
        closure()
        gates.exit.pass() 
    } 
}

func meetInStudy(id: Int) {
    print("Elf", id, "meeting in the study")
}
func deliverToys(id: Int) {
    print("Reindeer", id, "delivering toys")
}

let elf1 : Group -> Int -> Void = 
    { g in { id in helper1(g)( { meetInStudy(id) } ) } }

func elf2(gp: Group)(id: Int) { 
    return helper1(gp)({ meetInStudy(id) })
}

let reindeer1 : Group -> Int -> Void =
    { g in { id in helper1(g)( { deliverToys(id) } ) } }

func replace2<A,B,C,D>(f: A -> B -> C, g: D -> B) -> A -> D -> C {
    return { a in 
        return { d in 
            return f(a)(g(d)) } }
}

func defered<A, B>(f: A -> B) -> A -> B -> Void {
    return { a in { b in f(a); return } }
}
let d : (Int -> ()) -> Int -> () -> () = defered

let elf3 = replace2(helper1, g: defered(meetInStudy) )
let reindeer3 = replace2(helper1, g: defered(deliverToys))

(1...10).map { $0 }

let main : Int = {
   
    let elf_Group = Group(maxSize: 3)
    let elves = (1...10).map { elf3(elf_Group)($0) }
    let rein_Group = Group(maxSize: 9)
    let reins = (1...9).map { reindeer3(rein_Group)($0) }   
   
   return 0 
}()






let f : (Int, Int) -> Int = (+) //|*| (*2)
let g = (*2)
let h = f |*| g
var str = "Finished :)"







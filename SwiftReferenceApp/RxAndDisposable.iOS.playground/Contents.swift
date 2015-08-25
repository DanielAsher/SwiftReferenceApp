//: Playground - noun: a place where people can play

import UIKit
import RxSwift

var str = "Hello, playground"

var envColor = UIColor.blackColor()

class ColorSet : Disposable {
    
    let previousColor: UIColor
    
    init(color: UIColor) 
    {
        previousColor = envColor
        envColor = color
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 20))
        text.textColor = color
        text.text = "Set envColor to \(color)" 
    }
    
    func dispose() {
        envColor = previousColor
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 20))
        text.textColor = previousColor
        text.text = "Restored \(previousColor) to envColor" 
    }
}

// .NET's `using` language construct in a two-line function!
func using(disposable: Disposable, closure: () -> ()) 
{
   closure()
   disposable.dispose() 
}

func using<T : Disposable>(disposable: T, closure: (T) -> Void) 
{
    closure(disposable)
    disposable.dispose() 
}

using(ColorSet(color: UIColor.redColor()) ) {
    print("hello")
    using(ColorSet(color: UIColor.blueColor())) {
        print("goodbye")
    }
}

using(ColorSet(color: UIColor.redColor()) ) { (color: ColorSet) in
    print(color)
    print("hello")
    using(ColorSet(color: UIColor.blueColor())) {
        print("goodbye")
    }
}














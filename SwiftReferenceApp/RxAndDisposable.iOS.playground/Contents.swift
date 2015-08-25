//: Playground - noun: a place where people can play

import UIKit
//import RxSwift

var str = "Hello, playground"

var envColor = UIColor.blackColor()

// Straight from Rx
protocol Disposable {
    func dispose()
}

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

let red = ColorSet(color: UIColor.redColor()) 
let blue = ColorSet(color: UIColor.blueColor())
let green = ColorSet(color: UIColor.greenColor())

using(red) {
    print("I want to change to blue, but how do I remember I used to be green?")
    using(blue) {
        print("ooh - nice in blue")
        using(green) {
            print("yikes! what color was I before blue? oh - I don't need to worry. `using` is taking care of it.")
        }
    }
}














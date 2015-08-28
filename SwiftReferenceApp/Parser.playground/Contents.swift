
import Cocoa
import Box
import Madness
import Prelude

var str = "Hello, playground"

let stringToSave = "Your text"

let bundle = NSBundle.mainBundle()

let myFilePath = bundle.pathForResource("ApplicationSchema", ofType: "dot")

var error:NSError?

var content = String(contentsOfFile:myFilePath!, encoding:NSUTF8StringEncoding, error: &error)






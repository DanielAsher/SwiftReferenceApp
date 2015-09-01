
import Cocoa

let bundle = NSBundle.mainBundle()

func getDotFileAsString(name: String) -> String 
{
    let dotFilePath = bundle.pathForResource(name, ofType: ".dot.txt")    
    var error:NSError?
    let string = String(
        contentsOfFile: dotFilePath!, 
        encoding:NSUTF8StringEncoding, 
        error: &error)!
    return string
}



public var simpleGraphDotString = getDotFileAsString("SimpleGraph")

public var applicationSchema = getDotFileAsString("ApplicationSchema")

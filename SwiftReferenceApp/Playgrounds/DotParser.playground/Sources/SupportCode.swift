
import Cocoa

let bundle = NSBundle.mainBundle()

func getDotFileAsString(name: String) -> String 
{
    let dotFilePath = bundle.pathForResource(name, ofType: ".dot.txt")    
    let string = try! String(
        contentsOfFile: dotFilePath!, 
        encoding:NSUTF8StringEncoding)
        
    return string
}



public var simpleGraphDotString = getDotFileAsString("SimpleGraph")

public var applicationSchema = getDotFileAsString("ApplicationSchema")

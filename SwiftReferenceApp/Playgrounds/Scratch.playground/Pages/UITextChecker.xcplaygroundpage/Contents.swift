//: [Previous](@previous)

import Foundation
import UIKit
var str : NSString = "Hello, playgund"
let strRange = str.rangeOfString(str as String)
let checker = UITextChecker()



//str.

let misspelledRange = checker.rangeOfMisspelledWordInString(str as String, range: strRange, startingAt: 0, wrap: false, language: "en")

let guessWords = 
     checker.guessesForWordRange(misspelledRange, inString: str as String, language: "en")

let str2 = "What's nex"
let nsstr2 = NSString(string: str2)
let partialWordRange = nsstr2.rangeOfString("nex")

let completions = checker.completionsForPartialWordRange(partialWordRange, inString: str2, language: "en")

//extension String {
//    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
//        let from16 = advance(utf16.startIndex, nsRange.location, utf16.endIndex)
//        let to16 = advance(from16, nsRange.length, utf16.endIndex)
//        if let from = String.Index(from16, within: self),
//            let to = String.Index(to16, within: self) {
//                return from ..< to
//        }
//        return nil
//    }
//}
//: [Next](@next)

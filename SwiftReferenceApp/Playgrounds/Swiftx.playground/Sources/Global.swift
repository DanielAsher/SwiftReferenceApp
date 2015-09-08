import Foundation

extension String {
    public func padding(fieldLength: Int) -> String {
        var formatedString: String = ""
        formatedString += self
        let padLength = max(1, fieldLength - self.characters.count)
        for _ in 1...padLength {
            formatedString += " "
        }
        
        return formatedString
    }
    
    public func padding(fieldLength: Int, paddingChar: String) -> String {
        var formatedString: String = ""
        formatedString += self
        let padLength = max(1, fieldLength - self.characters.count)
        for _ in 1...padLength {
            formatedString += paddingChar
        }
        
        return formatedString
    }
}


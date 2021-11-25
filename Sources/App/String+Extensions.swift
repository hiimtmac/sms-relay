import Foundation

extension String {
    func numbers() throws -> [Self] {
        let regex = try NSRegularExpression(pattern: "\\+[0-9]{11}")
        let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        return results
            .map { String(self[Range($0.range, in: self)!]) }
            .map { $0.uppercased() }
    }
}

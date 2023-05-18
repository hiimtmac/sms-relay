@testable import Lambda
import AWSLambdaEvents
import XCTest

final class SMSRelayTests: XCTestCase {
    func testExample() throws {
        let body = """
        +12223334444 +12223334444
        This is pretty cool
        """
        
        let components = body.components(separatedBy: "\n")
        
        if
            components.count >= 2,
            let numbers = try? components[0].numbers(),
            numbers.count == 1,
            let number = numbers.first
        {
            let body = components
                .dropFirst()
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            print(number, body)
        } else {
            print(body)
        }
    }
}

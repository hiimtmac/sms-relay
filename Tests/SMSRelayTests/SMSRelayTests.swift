import XCTest
@testable import App

final class SMSRelayTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let body = """
        +12223334444
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

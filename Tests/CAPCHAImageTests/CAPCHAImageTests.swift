import XCTest
@testable import CAPCHAImage

final class CAPCHAImageTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(CAPCHAImage().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}

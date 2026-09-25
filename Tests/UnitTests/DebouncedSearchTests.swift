import XCTest
@testable import DiscountCards

final class DebouncedSearchTests: XCTestCase {
    func testDebounceUpdatesAfterDelay() {
        let debouncer = DebouncedSearch(delayMs: 50)
        let expectation = expectation(description: "Debounced text received")
        
        debouncer.update(text: "Евро")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            XCTAssertEqual(debouncer.debouncedText, "Евро")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testDebounceTrimsWhitespace() {
        let debouncer = DebouncedSearch(delayMs: 50)
        let expectation = expectation(description: "Trimmed text received")
        
        debouncer.update(text: "   Минск   ")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            XCTAssertEqual(debouncer.debouncedText, "Минск")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
}

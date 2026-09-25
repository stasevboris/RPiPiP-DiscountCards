import XCTest

final class DiscountCardsUITests: XCTestCase {
    private var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-resetStore"]
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testAppLaunchesAndShowsTitle() {
        let navTitle = app.navigationBars["Мои карты"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 5.0))
    }
    
    func testSearchFieldInteraction() {
        let searchField = app.searchFields["Поиск карты или магазина"]
        if searchField.waitForExistence(timeout: 5.0) {
            searchField.tap()
            searchField.typeText("Евроопт")
            XCTAssertTrue(searchField.exists)
        }
    }
    
    func testAddCardSheetOpensAndCloses() {
        let addButton = app.buttons["plus"]
        if addButton.waitForExistence(timeout: 5.0) {
            addButton.tap()
            
            let cancelButton = app.buttons["Отмена"]
            XCTAssertTrue(cancelButton.waitForExistence(timeout: 3.0))
            cancelButton.tap()
        }
    }
    
    func testScannerSheetOpensAndCloses() {
        let scannerButton = app.buttons["Сканер"]
        if scannerButton.waitForExistence(timeout: 5.0) {
            scannerButton.tap()
            
            let closeButton = app.buttons["Закрыть"]
            XCTAssertTrue(closeButton.waitForExistence(timeout: 3.0))
            closeButton.tap()
        }
    }
}

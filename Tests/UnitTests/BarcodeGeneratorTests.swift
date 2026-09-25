import XCTest
@testable import DiscountCards

final class BarcodeGeneratorTests: XCTestCase {
    private var generator: BarcodeGenerating!
    
    override func setUp() {
        super.setUp()
        generator = CoreImageBarcodeGenerator()
    }
    
    override func tearDown() {
        generator = nil
        super.tearDown()
    }
    
    func testMakeBarcodeCode128Success() {
        let image = generator.makeBarcodeImage(from: "5501234987654", format: .code128, targetSize: CGSize(width: 300, height: 100))
        XCTAssertNotNil(image)
        XCTAssertGreaterThan(image?.size.width ?? 0, 0)
        XCTAssertGreaterThan(image?.size.height ?? 0, 0)
    }
    
    func testMakeBarcodeEAN13Success() {
        let image = generator.makeBarcodeImage(from: "9900012345678", format: .ean13, targetSize: CGSize(width: 300, height: 100))
        XCTAssertNotNil(image)
    }
    
    func testMakeBarcodeQRSuccess() {
        let image = generator.makeBarcodeImage(from: "https://github.com/stasevboris", format: .qr, targetSize: CGSize(width: 200, height: 200))
        XCTAssertNotNil(image)
    }
    
    func testMakeBarcodeEmptyStringReturnsNil() {
        let image = generator.makeBarcodeImage(from: "   ", format: .code128, targetSize: CGSize(width: 300, height: 100))
        XCTAssertNil(image)
    }
}

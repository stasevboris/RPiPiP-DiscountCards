import XCTest
import SwiftData
@testable import DiscountCards

@MainActor
final class DiscountCardEntityTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    
    override func setUp() {
        super.setUp()
        let schema = Schema([DiscountCardEntity.self, DeletedRecordEntity.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try! ModelContainer(for: schema, configurations: config)
        context = container.mainContext
    }
    
    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }
    
    func testCardEntityCreationAndFetch() throws {
        let card = DiscountCardEntity(
            name: "Е-Плюс",
            cardNumber: "9900012345678",
            barcodeFormat: .ean13,
            categoryId: "supermarket",
            discountPercent: 5
        )
        context.insert(card)
        try context.save()
        
        let fetched = try context.fetch(FetchDescriptor<DiscountCardEntity>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.name, "Е-Плюс")
        XCTAssertEqual(fetched.first?.cardNumber, "9900012345678")
        XCTAssertEqual(fetched.first?.barcodeFormat, .ean13)
    }
    
    func testBarcodeFormatRawValueConversion() {
        let card = DiscountCardEntity(name: "Test", cardNumber: "123", categoryId: "other")
        card.barcodeFormat = .qr
        XCTAssertEqual(card.barcodeFormatRaw, "QR")
        XCTAssertEqual(card.barcodeFormat, .qr)
        
        card.barcodeFormat = .code128
        XCTAssertEqual(card.barcodeFormatRaw, "CODE128")
        XCTAssertEqual(card.barcodeFormat, .code128)
    }
}

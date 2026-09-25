import XCTest
@testable import DiscountCards

final class CardExporterTests: XCTestCase {
    private var testCards: [DiscountCardEntity]!
    
    override func setUp() {
        super.setUp()
        testCards = [
            DiscountCardEntity(name: "Евроопт", cardNumber: "9900012345678", categoryId: "supermarket", discountPercent: 5, note: "Основная карта"),
            DiscountCardEntity(name: "Mark Formelle", cardNumber: "2800045612340", categoryId: "fashion", discountPercent: 10, note: "Одежда")
        ]
    }
    
    override func tearDown() {
        testCards = nil
        super.tearDown()
    }
    
    func testExportJSONContainsValidStructure() throws {
        let (data, filename) = try CardExporter.exportData(cards: testCards, format: .json)
        XCTAssertTrue(filename.hasSuffix(".json"))
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        XCTAssertNotNil(json)
        XCTAssertEqual(json?["format"] as? String, "discount-cards-exchange")
        XCTAssertEqual(json?["count"] as? Int, 2)
        
        let cards = json?["cards"] as? [[String: Any]]
        XCTAssertEqual(cards?.count, 2)
        XCTAssertEqual(cards?.first?["name"] as? String, "Евроопт")
    }
    
    func testExportCSVHasBOMAndSemicolonDelimiter() throws {
        let (data, filename) = try CardExporter.exportData(cards: testCards, format: .csv)
        XCTAssertTrue(filename.hasSuffix(".csv"))
        
        // Проверка BOM UTF-8 (EF BB BF)
        XCTAssertGreaterThan(data.count, 3)
        XCTAssertEqual(data[0], 0xEF)
        XCTAssertEqual(data[1], 0xBB)
        XCTAssertEqual(data[2], 0xBF)
        
        let content = String(data: data.subdata(in: 3..<data.count), encoding: .utf8)
        XCTAssertNotNil(content)
        XCTAssertTrue(content!.contains("Название;Номер карты;Категория;Скидка;Заметка"))
        XCTAssertTrue(content!.contains("Евроопт"))
        XCTAssertTrue(content!.contains("Mark Formelle"))
    }
}

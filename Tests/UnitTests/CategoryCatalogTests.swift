import XCTest
@testable import DiscountCards

final class CategoryCatalogTests: XCTestCase {
    func testCatalogLoadsFromValidData() throws {
        let json = """
        {
          "version": 1,
          "categories": [
            { "id": "cat1", "name": "Тест 1", "icon": "star", "color": "#ff0000" },
            { "id": "cat2", "name": "Тест 2", "icon": "cart", "color": "#00ff00" }
          ]
        }
        """.data(using: .utf8)!
        
        let catalog = try CategoryCatalog(data: json)
        XCTAssertEqual(catalog.categories.count, 2)
        XCTAssertEqual(catalog.category(for: "cat1").name, "Тест 1")
        XCTAssertEqual(catalog.category(for: "cat2").icon, "cart")
    }
    
    func testCatalogReturnsFallbackForUnknownCategory() {
        let catalog = CategoryCatalog.shared
        let unknown = catalog.category(for: "non_existent_id")
        XCTAssertEqual(unknown.id, "non_existent_id")
        XCTAssertEqual(unknown.name, "Другое")
    }
    
    func testDefaultCatalogHasStandardCategories() {
        let catalog = CategoryCatalog.shared
        XCTAssertFalse(catalog.categories.isEmpty)
        let supermarket = catalog.category(for: "supermarket")
        XCTAssertEqual(supermarket.name, "Супермаркеты")
    }
}

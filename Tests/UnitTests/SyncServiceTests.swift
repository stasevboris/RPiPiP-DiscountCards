import XCTest
import Combine
import SwiftData
@testable import DiscountCards

private final class MockAPI: DiscountCardsAPI {
    var dtos: [DiscountCardDTO] = []
    var errorToThrow: APIError? = nil
    
    func fetchCards() -> AnyPublisher<[DiscountCardDTO], APIError> {
        if let err = errorToThrow {
            return Fail(error: err).eraseToAnyPublisher()
        }
        return Just(dtos)
            .setFailureType(to: APIError.self)
            .eraseToAnyPublisher()
    }
}

@MainActor
final class SyncServiceTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var mockAPI: MockAPI!
    private var syncService: SyncService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let schema = Schema([DiscountCardEntity.self, DeletedRecordEntity.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: config)
        context = container.mainContext
        mockAPI = MockAPI()
        syncService = SyncService(api: mockAPI, context: context)
    }
    
    override func tearDownWithError() throws {
        container = nil
        context = nil
        mockAPI = nil
        syncService = nil
        try super.tearDownWithError()
    }
    
    func testApplySnapshotInsertsNewCards() throws {
        let dtos = [
            DiscountCardDTO(id: "c1", name: "Серверная карта 1", cardNumber: "1111", barcodeFormat: "EAN13", categoryId: "supermarket", colorHex: "#ff0000", colorGradientEnd: nil, discountPercent: 5, note: nil),
            DiscountCardDTO(id: "c2", name: "Серверная карта 2", cardNumber: "2222", barcodeFormat: "CODE128", categoryId: "fashion", colorHex: "#00ff00", colorGradientEnd: nil, discountPercent: 10, note: "Тест")
        ]
        
        let report = try syncService.applySnapshot(dtos)
        XCTAssertEqual(report.inserted, 2)
        XCTAssertEqual(report.updated, 0)
        
        let all = try context.fetch(FetchDescriptor<DiscountCardEntity>())
        XCTAssertEqual(all.count, 2)
    }
    
    func testApplySnapshotPreservesLocallyModifiedCards() throws {
        let initialCard = DiscountCardEntity(name: "Моя правка", cardNumber: "1111", categoryId: "supermarket", remoteId: "c1", locallyModified: true)
        context.insert(initialCard)
        try context.save()
        
        let dtos = [
            DiscountCardDTO(id: "c1", name: "Имя с сервера", cardNumber: "1111", barcodeFormat: "EAN13", categoryId: "supermarket", colorHex: "#ff0000", colorGradientEnd: nil, discountPercent: 5, note: nil)
        ]
        
        let report = try syncService.applySnapshot(dtos)
        XCTAssertEqual(report.inserted, 0)
        XCTAssertEqual(report.updated, 0)
        
        let fetched = try context.fetch(FetchDescriptor<DiscountCardEntity>()).first
        XCTAssertEqual(fetched?.name, "Моя правка")
    }
    
    func testApplySnapshotSkipsDeletedRecords() throws {
        let deleted = DeletedRecordEntity(remoteId: "c1")
        context.insert(deleted)
        try context.save()
        
        let dtos = [
            DiscountCardDTO(id: "c1", name: "Удаленная пользователем", cardNumber: "1111", barcodeFormat: "EAN13", categoryId: "supermarket", colorHex: "#ff0000", colorGradientEnd: nil, discountPercent: 5, note: nil)
        ]
        
        let report = try syncService.applySnapshot(dtos)
        XCTAssertEqual(report.inserted, 0)
        
        let all = try context.fetch(FetchDescriptor<DiscountCardEntity>())
        XCTAssertEqual(all.count, 0)
    }
}

import Combine
import Foundation
import Observation
import SwiftData

public struct SyncReport: Equatable {
    public var inserted: Int = 0
    public var updated: Int = 0
    public var total: Int { inserted + updated }
}

@Observable
public final class SyncService {
    public enum State: Equatable {
        case idle
        case loading
        case synced(SyncReport, Date)
        case failed(String)
    }
    
    public private(set) var state: State = .idle
    private let api: DiscountCardsAPI
    private let context: ModelContext
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    
    public init(api: DiscountCardsAPI, context: ModelContext) {
        self.api = api
        self.context = context
    }
    
    public func syncOnLaunch() {
        guard state != .loading else { return }
        state = .loading
        
        api.fetchCards()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .failed(error.localizedDescription)
                }
            } receiveValue: { [weak self] dtos in
                guard let self else { return }
                do {
                    let report = try self.applySnapshot(dtos)
                    self.state = .synced(report, .now)
                } catch {
                    self.state = .failed(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    @discardableResult
    public func applySnapshot(_ dtos: [DiscountCardDTO]) throws -> SyncReport {
        var report = SyncReport()
        let deletedRecords = try context.fetch(FetchDescriptor<DeletedRecordEntity>())
        let deletedIds = Set(deletedRecords.map(\.remoteId))
        
        let localCards = try context.fetch(FetchDescriptor<DiscountCardEntity>())
        var cardsByRemote = Dictionary(localCards.compactMap { c in c.remoteId.map { ($0, c) } },
                                       uniquingKeysWith: { first, _ in first })
        
        for dto in dtos where !deletedIds.contains(dto.id) {
            if let existing = cardsByRemote[dto.id] {
                // Если пользователь не модифицировал запись локально — обновляем
                if !existing.locallyModified {
                    existing.name = dto.name
                    existing.cardNumber = dto.cardNumber
                    existing.categoryId = dto.categoryId
                    existing.colorHex = dto.colorHex
                    existing.discountPercent = dto.discountPercent
                    existing.note = dto.note ?? ""
                    report.updated += 1
                }
            } else {
                // Вставка новой серверной карты
                let newCard = DiscountCardEntity(
                    name: dto.name,
                    cardNumber: dto.cardNumber,
                    barcodeFormat: BarcodeFormat(rawValue: dto.barcodeFormat) ?? .ean13,
                    categoryId: dto.categoryId,
                    colorHex: dto.colorHex,
                    colorGradientEnd: dto.colorGradientEnd,
                    discountPercent: dto.discountPercent,
                    note: dto.note ?? "",
                    remoteId: dto.id,
                    locallyModified: false
                )
                context.insert(newCard)
                cardsByRemote[dto.id] = newCard
                report.inserted += 1
            }
        }
        
        try context.save()
        return report
    }
}

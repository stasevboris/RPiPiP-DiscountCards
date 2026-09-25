import Foundation
import Observation
import SwiftData
import UIKit

/// ViewModel экрана детальной информации карты
@Observable
public final class CardDetailViewModel {
    public let card: DiscountCardEntity
    private let generator: BarcodeGenerating
    
    @ObservationIgnored private var cachedBarcode: UIImage?
    public var isFullScreenPresented: Bool = false
    
    public init(card: DiscountCardEntity, generator: BarcodeGenerating = CoreImageBarcodeGenerator()) {
        self.card = card
        self.generator = generator
    }
    
    public var title: String { card.name }
    public var cardNumber: String { card.cardNumber }
    public var formattedNumber: String {
        let clean = card.cardNumber.replacingOccurrences(of: " ", with: "")
        if clean.count == 13 {
            let p1 = clean.prefix(1)
            let p2 = clean.dropFirst(1).prefix(6)
            let p3 = clean.suffix(6)
            return "\(p1) \(p2) \(p3)"
        }
        return clean
    }
    public var colorHex: String { card.colorHex }
    public var colorGradientEnd: String? { card.colorGradientEnd }
    public var note: String { card.note }
    public var discountText: String {
        if let d = card.discountPercent { return "\(d)%" }
        return "Бонусная"
    }
    
    public var barcodeImage: UIImage? {
        if let cachedBarcode { return cachedBarcode }
        guard let img = generator.makeBarcodeImage(from: card.cardNumber,
                                                   format: card.barcodeFormat,
                                                   targetSize: CGSize(width: 480, height: 160)) else {
            return nil
        }
        cachedBarcode = img
        return img
    }
    
    public func delete(context: ModelContext) {
        if let remoteId = card.remoteId {
            let deleted = DeletedRecordEntity(remoteId: remoteId)
            context.insert(deleted)
        }
        context.delete(card)
        try? context.save()
    }
}

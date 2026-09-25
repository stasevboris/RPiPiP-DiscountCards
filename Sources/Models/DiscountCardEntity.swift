import Foundation
import SwiftData

public enum BarcodeFormat: String, Codable, CaseIterable {
    case code128 = "CODE128"
    case ean13 = "EAN13"
    case qr = "QR"
}

@Model
public final class DiscountCardEntity {
    @Attribute(.unique) public var id: UUID
    public var name: String
    @Attribute(.unique) public var cardNumber: String
    public var barcodeFormatRaw: String
    public var categoryId: String
    public var colorHex: String
    public var colorGradientEnd: String?
    public var discountPercent: Int?
    public var note: String
    public var remoteId: String?
    public var locallyModified: Bool
    public var createdAt: Date
    
    public init(id: UUID = UUID(),
                name: String,
                cardNumber: String,
                barcodeFormat: BarcodeFormat = .ean13,
                categoryId: String,
                colorHex: String = "#e11d48",
                colorGradientEnd: String? = nil,
                discountPercent: Int? = 5,
                note: String = "",
                remoteId: String? = nil,
                locallyModified: Bool = false,
                createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.cardNumber = cardNumber
        self.barcodeFormatRaw = barcodeFormat.rawValue
        self.categoryId = categoryId
        self.colorHex = colorHex
        self.colorGradientEnd = colorGradientEnd
        self.discountPercent = discountPercent
        self.note = note
        self.remoteId = remoteId
        self.locallyModified = locallyModified
        self.createdAt = createdAt
    }
    
    public var barcodeFormat: BarcodeFormat {
        get { BarcodeFormat(rawValue: barcodeFormatRaw) ?? .ean13 }
        set { barcodeFormatRaw = newValue.rawValue }
    }
}

@Model
public final class DeletedRecordEntity {
    @Attribute(.unique) public var remoteId: String
    public var deletedAt: Date
    
    public init(remoteId: String, deletedAt: Date = .now) {
        self.remoteId = remoteId
        self.deletedAt = deletedAt
    }
}

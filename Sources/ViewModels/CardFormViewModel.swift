import Foundation
import Observation
import SwiftData

/// ViewModel формы добавления и редактирования дисконтной карты
@Observable
public final class CardFormViewModel {
    public var name: String = ""
    public var cardNumber: String = ""
    public var barcodeFormat: BarcodeFormat = .ean13
    public var categoryId: String = "supermarket"
    public var colorHex: String = "#e11d48"
    public var discountPercent: Int = 5
    public var note: String = ""
    public var errorMessage: String? = nil
    
    private let cardToEdit: DiscountCardEntity?
    private let context: ModelContext
    
    public init(card: DiscountCardEntity? = nil, initialCardNumber: String? = nil, context: ModelContext) {
        self.cardToEdit = card
        self.context = context
        
        if let card = card {
            self.name = card.name
            self.cardNumber = card.cardNumber
            self.barcodeFormat = card.barcodeFormat
            self.categoryId = card.categoryId
            self.colorHex = card.colorHex
            self.discountPercent = card.discountPercent ?? 5
            self.note = card.note
        } else if let num = initialCardNumber {
            self.cardNumber = num
        }
    }
    
    public var isEditing: Bool { cardToEdit != nil }
    public var title: String { isEditing ? "Редактировать карту" : "Новая карта" }
    
    public var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !cardNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public func save() -> Bool {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanNumber = cardNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanName.isEmpty else {
            errorMessage = "Укажите название карты"
            return false
        }
        guard !cleanNumber.isEmpty else {
            errorMessage = "Укажите номер карты"
            return false
        }
        
        do {
            if let existing = cardToEdit {
                existing.name = cleanName
                existing.cardNumber = cleanNumber
                existing.barcodeFormat = barcodeFormat
                existing.categoryId = categoryId
                existing.colorHex = colorHex
                existing.discountPercent = discountPercent
                existing.note = note
                existing.locallyModified = true
            } else {
                let newCard = DiscountCardEntity(
                    name: cleanName,
                    cardNumber: cleanNumber,
                    barcodeFormat: barcodeFormat,
                    categoryId: categoryId,
                    colorHex: colorHex,
                    discountPercent: discountPercent,
                    note: note,
                    remoteId: nil,
                    locallyModified: true
                )
                context.insert(newCard)
            }
            try context.save()
            return true
        } catch {
            errorMessage = "Ошибка сохранения: \(error.localizedDescription)"
            return false
        }
    }
}

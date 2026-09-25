import Foundation
import Observation
import SwiftData

/// Состояния и логика экрана сканирования штрихкодов
@Observable
public final class ScannerViewModel {
    public enum State: Equatable {
        case scanning
        case found(DiscountCardEntity)
        case unknownCard(cardNumber: String)
        case foreignBarcode(String)
    }
    
    private let context: ModelContext
    public private(set) var state: State = .scanning
    public private(set) var lastScannedCode: String?
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public func handleScannedBarcode(_ raw: String) {
        let code = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !code.isEmpty else { return }
        lastScannedCode = code
        
        let descriptor = FetchDescriptor<DiscountCardEntity>(predicate: #Predicate { $0.cardNumber == code })
        let matched = try? context.fetch(descriptor).first
        
        if let card = matched {
            state = .found(card)
        } else if code.hasPrefix("4810268") {
            // Демонстрационный префикс постороннего штрихкода товара
            state = .foreignBarcode(code)
        } else {
            state = .unknownCard(cardNumber: code)
        }
    }
    
    public func reset() {
        state = .scanning
        lastScannedCode = nil
    }
}

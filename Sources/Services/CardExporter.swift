import Foundation

public enum ExportFormat: String, CaseIterable, Identifiable {
    case json = "JSON"
    case csv = "CSV"
    public var id: String { rawValue }
}

public struct CardExporter {
    public struct ExportItem: Codable {
        public let name: String
        public let cardNumber: String
        public let category: String
        public let discount: String
        public let note: String
    }
    
    public struct ExportPayload: Codable {
        public let format: String
        public let version: Int
        public let exportedAt: String
        public let count: Int
        public let cards: [ExportItem]
    }
    
    public static func exportData(cards: [DiscountCardEntity], format: ExportFormat) throws -> (data: Data, filename: String) {
        let timestamp = Int(Date().timeIntervalSince1970)
        let baseName = "Cards_Export_\(timestamp)"
        
        switch format {
        case .json:
            let items = cards.map {
                ExportItem(name: $0.name, cardNumber: $0.cardNumber,
                           category: $0.categoryId, discount: "\($0.discountPercent ?? 0)%", note: $0.note)
            }
            let payload = ExportPayload(format: "discount-cards-exchange", version: 1,
                                        exportedAt: ISO8601DateFormatter().string(from: Date()),
                                        count: items.count, cards: items)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(payload)
            return (data, "\(baseName).json")
            
        case .csv:
            var lines = ["Название;Номер карты;Категория;Скидка;Заметка"]
            for c in cards {
                let row = [c.name, c.cardNumber, c.categoryId, "\(c.discountPercent ?? 0)%", c.note]
                    .map { item -> String in
                        let escaped = item.replacingOccurrences(of: "\"", with: "\"\"")
                        return "\"\(escaped)\""
                    }
                    .joined(separator: ";")
                lines.append(row)
            }
            let bom = Data([0xEF, 0xBB, 0xBF])
            let csvText = lines.joined(separator: "\r\n")
            let data = bom + (csvText.data(using: .utf8) ?? Data())
            return (data, "\(baseName).csv")
        }
    }
}

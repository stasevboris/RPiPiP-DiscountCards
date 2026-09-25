import SwiftUI

public struct CardRowView: View {
    public let card: DiscountCardEntity
    
    public init(card: DiscountCardEntity) {
        self.card = card
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            // Иконка-плашка цвета карты
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: card.colorHex),
                                Color(hex: card.colorGradientEnd ?? card.colorHex).opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: CategoryCatalog.shared.category(for: card.categoryId).icon)
                    .foregroundStyle(.white)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(card.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if let d = card.discountPercent {
                        Text("\(d)%")
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15))
                            .foregroundStyle(Color.accentColor)
                            .clipShape(Capsule())
                    }
                }
                
                Text(formattedNumber(card.cardNumber))
                    .font(.caption)
                    .fontDesign(.monospaced)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    private func formattedNumber(_ num: String) -> String {
        let clean = num.replacingOccurrences(of: " ", with: "")
        if clean.count == 13 {
            let p1 = clean.prefix(1)
            let p2 = clean.dropFirst(1).prefix(6)
            let p3 = clean.suffix(6)
            return "\(p1) \(p2) \(p3)"
        }
        return clean
    }
}

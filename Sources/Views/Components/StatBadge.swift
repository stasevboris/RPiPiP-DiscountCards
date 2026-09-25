import SwiftUI

public struct StatBadge: View {
    public let value: Int
    public let title: String
    public let icon: String
    
    public init(value: Int, title: String, icon: String) {
        self.value = value
        self.title = title
        self.icon = icon
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.tint)
                Spacer()
            }
            Text("\(value)")
                .font(.title2.bold())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

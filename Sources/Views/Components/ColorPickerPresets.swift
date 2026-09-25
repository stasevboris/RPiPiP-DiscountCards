import SwiftUI

public struct ColorPickerPresets: View {
    @Binding public var selectedColor: String
    
    private let presets = [
        "#e11d48", "#ea580c", "#d97706", "#16a34a",
        "#0284c7", "#2563eb", "#7c3aed", "#db2777",
        "#475569", "#0f172a"
    ]
    
    public init(selectedColor: Binding<String>) {
        self._selectedColor = selectedColor
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(presets, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: selectedColor == hex ? 3 : 0)
                        )
                        .onTapGesture {
                            selectedColor = hex
                        }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

extension Color {
    public init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch clean.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 128, 128, 128)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

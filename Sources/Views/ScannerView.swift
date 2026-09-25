import SwiftUI
import SwiftData

public struct ScannerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var viewModel: ScannerViewModel
    @State private var manualInput: String = ""
    @State private var showingManualInput = false
    @State private var targetNewCardNumber: String?
    @State private var targetFoundCard: DiscountCardEntity?
    
    public init(context: ModelContext) {
        _viewModel = State(initialValue: ScannerViewModel(context: context))
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Видоискатель сканера
                scannerOverlay
                
                // Результат сканирования
                resultStatusSection
                
                Spacer()
                
                // Симулятор сканирования для тестов и симулятора iOS
                simulatorMockSection
            }
            .padding()
            .navigationTitle("Сканер карт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
            .sheet(item: $targetNewCardNumberIdentifiable) { item in
                CardFormView(viewModel: CardFormViewModel(initialCardNumber: item.value, context: context))
            }
            .sheet(item: $targetFoundCard) { card in
                NavigationStack {
                    CardDetailView(card: card)
                }
            }
        }
    }
    
    private var targetNewCardNumberIdentifiable: StringIdentifiable? {
        targetNewCardNumber.map { StringIdentifiable(value: $0) }
    }
    
    private var scannerOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.85))
                .frame(height: 220)
            
            VStack(spacing: 12) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("Наведите камеру на штрихкод")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
    
    @ViewBuilder
    private var resultStatusSection: some View {
        switch viewModel.state {
        case .scanning:
            Text("Готов к сканированию")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
        case .found(let card):
            VStack(spacing: 8) {
                Label("Найдена карта: \(card.name)", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
                Button("Открыть карту") {
                    targetFoundCard = card
                }
                .buttonStyle(.borderedProminent)
            }
            
        case .unknownCard(let code):
            VStack(spacing: 8) {
                Label("Новая карта: \(code)", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.blue)
                Button("Добавить в кошелек") {
                    targetNewCardNumber = code
                }
                .buttonStyle(.borderedProminent)
            }
            
        case .foreignBarcode(let code):
            VStack(spacing: 8) {
                Label("Штрихкод товара: \(code)", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)
                Text("Это штрихкод товара, а не дисконтная карта")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var simulatorMockSection: some View {
        VStack(spacing: 10) {
            Text("Имитация сканирования (для тестов):")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            HStack {
                Button("Е-Плюс") {
                    viewModel.handleScannedBarcode("9900012345678")
                }
                Button("Mark Formelle") {
                    viewModel.handleScannedBarcode("2800045612340")
                }
                Button("Новая карта") {
                    viewModel.handleScannedBarcode("4810999888777")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            
            HStack {
                TextField("Ввести штрихкод вручную...", text: $manualInput)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)
                
                Button("Ввести") {
                    viewModel.handleScannedBarcode(manualInput)
                    manualInput = ""
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .disabled(manualInput.isEmpty)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct StringIdentifiable: Identifiable {
    let value: String
    var id: String { value }
}

extension DiscountCardEntity: Identifiable {}

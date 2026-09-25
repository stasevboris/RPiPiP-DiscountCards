import SwiftUI
import SwiftData

public struct CardDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: CardDetailViewModel
    @State private var isShowingEditSheet = false
    @State private var isShowingDeleteAlert = false
    @State private var copiedFeedback = false
    
    public init(card: DiscountCardEntity, generator: BarcodeGenerating = CoreImageBarcodeGenerator()) {
        _viewModel = State(initialValue: CardDetailViewModel(card: card, generator: generator))
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Визуальная дисконтная карта
                cardMockup
                
                // Секция штрихкода для кассы
                barcodeSection
                
                // Дополнительная информация и заметки
                infoSection
            }
            .padding()
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isShowingEditSheet = true
                    } label: {
                        Label("Редактировать", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        isShowingDeleteAlert = true
                    } label: {
                        Label("Удалить карту", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            CardFormView(viewModel: CardFormViewModel(card: viewModel.card, context: context))
        }
        .alert("Удаление карты", isPresented: $isShowingDeleteAlert) {
            Button("Отмена", role: .cancel) {}
            Button("Удалить", role: .destructive) {
                viewModel.delete(context: context)
                dismiss()
            }
        } message: {
            Text("Вы действительно хотите удалить карту «\(viewModel.title)»?")
        }
    }
    
    private var cardMockup: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(CategoryCatalog.shared.category(for: viewModel.card.categoryId).name.uppercased())
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.8))
                    Text(viewModel.title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: CategoryCatalog.shared.category(for: viewModel.card.categoryId).icon)
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.9))
            }
            
            Spacer()
            
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("НОМЕР КАРТЫ")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.7))
                    Text(viewModel.formattedNumber)
                        .font(.headline)
                        .fontDesign(.monospaced)
                        .foregroundStyle(.white)
                }
                Spacer()
                Text(viewModel.discountText)
                    .font(.headline.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.white.opacity(0.2))
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .frame(height: 200)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: viewModel.colorHex),
                    Color(hex: viewModel.colorGradientEnd ?? viewModel.colorHex).opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Color(hex: viewModel.colorHex).opacity(0.35), radius: 10, y: 5)
    }
    
    private var barcodeSection: some View {
        VStack(spacing: 12) {
            Text("ШТРИХКОД ДЛЯ СКАНИРОВАНИЯ")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            
            if let img = viewModel.barcodeImage {
                Image(uiImage: img)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(height: 110)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
            } else {
                ContentUnavailableView("Не удалось создать штрихкод", systemImage: "barcode.viewfinder")
                    .frame(height: 110)
            }
            
            HStack(spacing: 8) {
                Text(viewModel.cardNumber)
                    .font(.subheadline)
                    .fontDesign(.monospaced)
                
                Button {
                    UIPasteboard.general.string = viewModel.cardNumber
                    copiedFeedback = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        copiedFeedback = false
                    }
                } label: {
                    Image(systemName: copiedFeedback ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !viewModel.note.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Заметка")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text(viewModel.note)
                        .font(.body)
                }
                Divider()
            }
            
            HStack {
                Text("Формат штрихкода")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(viewModel.card.barcodeFormat.rawValue)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

import SwiftUI
import SwiftData

public struct CardFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CardFormViewModel
    
    public init(viewModel: CardFormViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            Form {
                Section("Данные карты") {
                    TextField("Название (напр., Евроопт)", text: $viewModel.name)
                    TextField("Номер карты / штрихкод", text: $viewModel.cardNumber)
                        .keyboardType(.numberPad)
                    
                    Picker("Формат штрихкода", selection: $viewModel.barcodeFormat) {
                        ForEach(BarcodeFormat.allCases, id: \.self) { fmt in
                            Text(fmt.rawValue).tag(fmt)
                        }
                    }
                }
                
                Section("Категория") {
                    Picker("Категория", selection: $viewModel.categoryId) {
                        ForEach(CategoryCatalog.shared.categories) { cat in
                            Label(cat.name, systemImage: cat.icon).tag(cat.id)
                        }
                    }
                }
                
                Section("Цветовое оформление") {
                    ColorPickerPresets(selectedColor: $viewModel.colorHex)
                }
                
                Section("Размер скидки (%)") {
                    Stepper("\(viewModel.discountPercent)%", value: $viewModel.discountPercent, in: 0...100, step: 1)
                }
                
                Section("Заметка") {
                    TextField("Дополнительные условия, примечания...", text: $viewModel.note, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                if let err = viewModel.errorMessage {
                    Section {
                        Text(err)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}

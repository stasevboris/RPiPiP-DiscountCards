import SwiftUI
import SwiftData

/// Главный экран приложения: каталог дисконтных карт, поиск, фильтрация и управление
public struct CardHomeView: View {
    @Environment(AppDependencies.self) private var dependencies
    @Environment(\.modelContext) private var context
    
    @Query(sort: \DiscountCardEntity.name, order: .forward)
    private var allCards: [DiscountCardEntity]
    
    @State private var selectedCategoryId: String? = nil
    @State private var searchText: String = ""
    @State private var isShowingAddCard = false
    @State private var isShowingScanner = false
    @State private var exportItem: ExportPayloadFile?
    
    public init() {}
    
    private var filteredCards: [DiscountCardEntity] {
        allCards.filter { card in
            let matchesCategory = (selectedCategoryId == nil) || (card.categoryId == selectedCategoryId)
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if query.isEmpty { return matchesCategory }
            let matchesQuery = card.name.localizedCaseInsensitiveContains(query)
                || card.cardNumber.localizedCaseInsensitiveContains(query)
                || card.note.localizedCaseInsensitiveContains(query)
            return matchesCategory && matchesQuery
        }
    }
    
    public var body: some View {
        NavigationStack {
            List {
                // Строка сетевой синхронизации (ЛР 4)
                Section {
                    SyncStatusRow(state: dependencies.syncService.state) {
                        dependencies.syncService.syncOnLaunch()
                    }
                }
                
                // Сводная статистика (ЛР 1)
                summarySection
                
                // Фильтрация по категориям (ЛР 1 & ЛР 3)
                categoryFilterSection
                
                // Список карт (ЛР 1-4)
                cardsSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Мои карты")
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Поиск карты или магазина")
            .onChange(of: searchText) { _, newValue in
                dependencies.debouncedSearch.update(text: newValue)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Сканер", systemImage: "barcode.viewfinder")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Menu {
                            Button {
                                exportCards(format: .json)
                            } label: {
                                Label("Экспорт в JSON", systemImage: "curlybraces")
                            }
                            Button {
                                exportCards(format: .csv)
                            } label: {
                                Label("Экспорт в CSV (Excel)", systemImage: "tablecells")
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        
                        Button {
                            isShowingAddCard = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingAddCard) {
                CardFormView(viewModel: CardFormViewModel(context: context))
            }
            .sheet(isPresented: $isShowingScanner) {
                ScannerView(context: context)
            }
            .sheet(item: $exportItem) { item in
                ShareActivityView(data: item.data, filename: item.filename)
            }
        }
    }
    
    private var summarySection: some View {
        Section {
            HStack(spacing: 12) {
                StatBadge(value: allCards.count, title: "карт в кошельке", icon: "creditcard.fill")
                StatBadge(value: Set(allCards.map(\.categoryId)).count, title: "категорий", icon: "folder.fill")
                StatBadge(value: allCards.compactMap(\.discountPercent).max() ?? 0, title: "% макс. скидка", icon: "percent")
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        }
    }
    
    private var categoryFilterSection: some View {
        Section("Категории") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryPill(name: "Все", icon: "square.grid.2x2", isSelected: selectedCategoryId == nil) {
                        selectedCategoryId = nil
                    }
                    ForEach(dependencies.categoryCatalog.categories) { category in
                        CategoryPill(name: category.name, icon: category.icon,
                                     isSelected: selectedCategoryId == category.id) {
                            selectedCategoryId = category.id
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var cardsSection: some View {
        Section("Список карт (\(filteredCards.count))") {
            if filteredCards.isEmpty {
                ContentUnavailableView(
                    searchText.isEmpty ? "Кошелек пуст" : "Ничего не найдено",
                    systemImage: searchText.isEmpty ? "creditcard" : "magnifyingglass",
                    description: Text(searchText.isEmpty ? "Добавьте первую карту вручную или с помощью сканера" : "Попробуйте изменить запрос")
                )
            } else {
                ForEach(filteredCards) { card in
                    NavigationLink {
                        CardDetailView(card: card, generator: dependencies.barcodeGenerator)
                    } label: {
                        CardRowView(card: card)
                    }
                }
                .onDelete(perform: deleteCards)
            }
        }
    }
    
    private func deleteCards(at offsets: IndexSet) {
        for index in offsets {
            let card = filteredCards[index]
            if let remoteId = card.remoteId {
                let deleted = DeletedRecordEntity(remoteId: remoteId)
                context.insert(deleted)
            }
            context.delete(card)
        }
        try? context.save()
    }
    
    private func exportCards(format: ExportFormat) {
        guard let result = try? CardExporter.exportData(cards: allCards, format: format) else { return }
        exportItem = ExportPayloadFile(data: result.data, filename: result.filename)
    }
}

private struct ExportPayloadFile: Identifiable {
    let id = UUID()
    let data: Data
    let filename: String
}

private struct ShareActivityView: UIViewControllerRepresentable {
    let data: Data
    let filename: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: tempURL)
        return UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

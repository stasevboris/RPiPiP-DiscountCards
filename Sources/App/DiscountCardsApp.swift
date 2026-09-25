import SwiftUI
import SwiftData

@main
struct DiscountCardsApp: App {
    private let modelContainer: ModelContainer
    @State private var dependencies: AppDependencies
    
    init() {
        let args = ProcessInfo.processInfo.arguments
        let inMemory = args.contains("-uiTesting")
        let schema = Schema([
            DiscountCardEntity.self,
            DeletedRecordEntity.self
        ])
        
        let config: ModelConfiguration
        if inMemory {
            config = ModelConfiguration("DiscountCards", schema: schema, isStoredInMemoryOnly: true)
        } else {
            let storeURL = URL.applicationSupportDirectory.appending(path: "DiscountCards.store")
            if args.contains("-resetStore") {
                try? FileManager.default.removeItem(at: storeURL)
            }
            config = ModelConfiguration(schema: schema, url: storeURL)
        }
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Не удалось инициализировать хранилище SwiftData: \(error)")
        }
        
        let context = modelContainer.mainContext
        _dependencies = State(initialValue: AppDependencies(context: context))
    }
    
    var body: some Scene {
        WindowGroup {
            CardHomeView()
                .environment(dependencies)
                .task {
                    // Загрузка/обновление начальных данных через REST API при старте
                    dependencies.syncService.syncOnLaunch()
                }
        }
        .modelContainer(modelContainer)
    }
}

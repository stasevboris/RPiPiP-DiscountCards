import Foundation
import Observation
import SwiftData

/// Централизованный контейнер зависимостей приложения
@Observable
public final class AppDependencies {
    public let context: ModelContext
    public let syncService: SyncService
    public let apiClient: DiscountCardsAPI
    public let barcodeGenerator: BarcodeGenerating
    public let categoryCatalog: CategoryCatalog
    public let debouncedSearch: DebouncedSearch
    
    public init(context: ModelContext,
                apiClient: DiscountCardsAPI = DiscountCardsAPIClient(),
                barcodeGenerator: BarcodeGenerating = CoreImageBarcodeGenerator(),
                categoryCatalog: CategoryCatalog = .shared) {
        self.context = context
        self.apiClient = apiClient
        self.barcodeGenerator = barcodeGenerator
        self.categoryCatalog = categoryCatalog
        self.debouncedSearch = DebouncedSearch()
        self.syncService = SyncService(api: apiClient, context: context)
    }
}

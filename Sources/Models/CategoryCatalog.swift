import Foundation

/// Каталог категорий, загружаемый из неизменяемого JSON-файла
public final class CategoryCatalog {
    public static let shared = CategoryCatalog()
    
    public struct CategoryItem: Decodable, Identifiable, Hashable {
        public let id: String
        public let name: String
        public let icon: String
        public let color: String
        
        public init(id: String, name: String, icon: String, color: String) {
            self.id = id
            self.name = name
            self.icon = icon
            self.color = color
        }
    }
    
    private struct RootFile: Decodable {
        let version: Int
        let categories: [CategoryItem]
    }
    
    public let categories: [CategoryItem]
    private let map: [String: CategoryItem]
    
    public init(data: Data) throws {
        let root = try JSONDecoder().decode(RootFile.self, from: data)
        self.categories = root.categories
        self.map = Dictionary(uniqueKeysWithValues: root.categories.map { ($0.id, $0) })
    }
    
    public convenience init() {
        if let url = Bundle.main.url(forResource: "categories", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let catalog = try? CategoryCatalog(data: data) {
            self.init(categories: catalog.categories, map: catalog.map)
            return
        }
        
        // Fallback встроенные категории
        let defaults: [CategoryItem] = [
            CategoryItem(id: "supermarket", name: "Супермаркеты", icon: "cart.fill", color: "#16a34a"),
            CategoryItem(id: "fashion", name: "Одежда и обувь", icon: "tshirt.fill", color: "#ea580c"),
            CategoryItem(id: "electronics", name: "Электроника", icon: "tv.fill", color: "#2563eb"),
            CategoryItem(id: "pharmacy", name: "Аптеки и здоровье", icon: "cross.case.fill", color: "#dc2626"),
            CategoryItem(id: "cosmetics", name: "Косметика и быт", icon: "sparkles", color: "#db2777"),
            CategoryItem(id: "cafe", name: "Кафе и рестораны", icon: "cup.and.saucer.fill", color: "#d97706"),
            CategoryItem(id: "gas", name: "АЗС и авто", icon: "fuelpump.fill", color: "#4f46e5"),
            CategoryItem(id: "kids", name: "Детские товары", icon: "figure.and.child.holdinghands", color: "#0891b2"),
            CategoryItem(id: "other", name: "Другое", icon: "creditcard.fill", color: "#64748b")
        ]
        self.init(categories: defaults, map: Dictionary(uniqueKeysWithValues: defaults.map { ($0.id, $0) }))
    }
    
    private init(categories: [CategoryItem], map: [String: CategoryItem]) {
        self.categories = categories
        self.map = map
    }
    
    public func category(for id: String) -> CategoryItem {
        map[id] ?? CategoryItem(id: id, name: "Другое", icon: "creditcard.fill", color: "#64748b")
    }
}

import Combine
import Foundation

public struct DiscountCardDTO: Codable, Equatable {
    public let id: String
    public let name: String
    public let cardNumber: String
    public let barcodeFormat: String
    public let categoryId: String
    public let colorHex: String
    public let colorGradientEnd: String?
    public let discountPercent: Int?
    public let note: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, note
        case cardNumber = "card_number"
        case barcodeFormat = "barcode_format"
        case categoryId = "category_id"
        case colorHex = "color_hex"
        case colorGradientEnd = "color_gradient_end"
        case discountPercent = "discount_percent"
    }
}

public enum APIError: LocalizedError, Equatable {
    case transport(String)
    case badStatus(Int)
    case decoding(String)
    
    public var errorDescription: String? {
        switch self {
        case .transport(let msg): return "Сетевая ошибка: \(msg)"
        case .badStatus(let code): return "Сервер вернул статус \(code)"
        case .decoding: return "Ошибка обработки ответа сервера"
        }
    }
}

public protocol DiscountCardsAPI {
    func fetchCards() -> AnyPublisher<[DiscountCardDTO], APIError>
}

public final class DiscountCardsAPIClient: DiscountCardsAPI {
    public static let defaultURL = URL(string: "https://my-json-server.typicode.com/stasevboris/RPiPiP-DiscountCards/cards")!
    private let url: URL
    private let session: URLSession
    
    public init(url: URL = defaultURL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }
    
    public func fetchCards() -> AnyPublisher<[DiscountCardDTO], APIError> {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.timeoutInterval = 10
        
        return session.dataTaskPublisher(for: req)
            .mapError { APIError.transport($0.localizedDescription) }
            .tryMap { data, response -> Data in
                guard let http = response as? HTTPURLResponse else { throw APIError.badStatus(-1) }
                guard (200..<300).contains(http.statusCode) else { throw APIError.badStatus(http.statusCode) }
                return data
            }
            .decode(type: [DiscountCardDTO].self, decoder: JSONDecoder())
            .mapError { err -> APIError in
                if let api = err as? APIError { return api }
                return .decoding(err.localizedDescription)
            }
            .retry(1)
            .eraseToAnyPublisher()
    }
}

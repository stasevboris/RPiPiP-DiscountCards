import Combine
import Foundation
import Observation

/// Реактивный поиск «на лету» с задержкой ввода 250 мс через Combine
@Observable
public final class DebouncedSearch {
    public private(set) var debouncedText: String = ""
    @ObservationIgnored private let subject = PassthroughSubject<String, Never>()
    @ObservationIgnored private var cancellable: AnyCancellable?
    
    public init(delayMs: Int = 250) {
        cancellable = subject
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .debounce(for: .milliseconds(delayMs), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.debouncedText = text
            }
    }
    
    public func update(text: String) {
        subject.send(text)
    }
}

import SwiftUI

public struct SyncStatusRow: View {
    public let state: SyncService.State
    public let onRetry: () -> Void
    
    public init(state: SyncService.State, onRetry: @escaping () -> Void) {
        self.state = state
        self.onRetry = onRetry
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            switch state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
                    .controlSize(.small)
                Text("Синхронизация с сервером...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            case .synced(let report, _):
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
                Text("Сервер: добавлено \(report.inserted), обновлено \(report.updated)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            case .failed(let message):
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Button("Повтор", action: onRetry)
                    .font(.caption.bold())
                    .buttonStyle(.bordered)
                    .controlSize(.mini)
            }
        }
        .padding(.vertical, 4)
    }
}

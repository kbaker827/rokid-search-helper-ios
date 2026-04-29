import SwiftUI

struct HistoryView: View {
    @ObservedObject var history: SearchHistory
    @ObservedObject var vm: SearchViewModel

    var body: some View {
        NavigationStack {
            Group {
                if history.entries.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(history.entries) { entry in
                            Button {
                                vm.query = entry.query
                                vm.search()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.query)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                        .lineLimit(2)
                                    Text(entry.answer)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                    HStack {
                                        Text(entry.source)
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                        Spacer()
                                        Text(entry.timestamp, style: .relative)
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                if !history.entries.isEmpty {
                    Button("Clear", role: .destructive) { history.clear() }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.xmark")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No search history yet")
                .foregroundStyle(.secondary)
        }
    }
}

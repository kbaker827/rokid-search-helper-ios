import SwiftUI

struct SearchView: View {
    @ObservedObject var vm: SearchViewModel
    @FocusState private var focused: Bool

    private var settings: Settings { vm.settingsStore.settings }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar
                    .padding()

                Divider()

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Rokid Search Helper")
            .navigationBarTitleDisplayMode(.inline)
            .background(settings.highContrast ? Color.black.ignoresSafeArea() : Color(.systemBackground).ignoresSafeArea())
        }
    }

    // MARK: - Search bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Ask anything…", text: $vm.query, axis: .vertical)
                    .focused($focused)
                    .lineLimit(1...3)
                    .submitLabel(.search)
                    .onSubmit { vm.search() }
                if !vm.query.isEmpty {
                    Button { vm.clear() } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemFill))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button(action: vm.search) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(vm.query.isEmpty ? .secondary : .blue)
            }
            .disabled(vm.query.isEmpty)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch vm.state {
        case .idle:
            idleView
        case .searching:
            searchingView
        case .result(let q, let a, let src):
            ScrollView {
                ResultCardView(
                    query: q, answer: a, source: src,
                    fontSize: settings.displayFontSize,
                    highContrast: settings.highContrast
                )
                .padding()
            }
        case .error(let msg):
            errorView(msg)
        }
    }

    private var idleView: some View {
        VStack(spacing: 16) {
            Image(systemName: "glasses")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Type a question and press Search")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if !vm.history.entries.isEmpty {
                recentSearches
            }
        }
        .padding(32)
    }

    private var recentSearches: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            ForEach(vm.history.entries.prefix(5)) { entry in
                Button {
                    vm.query = entry.query
                    vm.search()
                } label: {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(entry.query)
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.top, 16)
        .frame(maxWidth: 400, alignment: .leading)
    }

    private var searchingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Searching…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try again") { focused = true }
                .buttonStyle(.bordered)
        }
        .padding(32)
    }
}

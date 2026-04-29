import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: SettingsStore
    @ObservedObject var glassesServer: GlassesDisplayServer
    @State private var isDirty = false

    var body: some View {
        NavigationStack {
            Form {
                displaySection
                aiSection
                glassesSection
                aboutSection
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { isDirty = false }
                        .disabled(!isDirty)
                }
            }
            .onChange(of: store.settings) { _ in isDirty = true }
        }
    }

    private var displaySection: some View {
        Section("Display") {
            Toggle("High Contrast (glasses-optimized)", isOn: $store.settings.highContrast)
            VStack(alignment: .leading) {
                Text("Answer Font Size: \(Int(store.settings.displayFontSize))pt")
                Slider(value: $store.settings.displayFontSize, in: 14...36, step: 1)
            }
        }
    }

    private var aiSection: some View {
        Section("AI Fallback (optional)") {
            Toggle("Use AI when no instant answer found", isOn: $store.settings.useAiFallback)
            SecureField("OpenAI API Key", text: $store.settings.openAiApiKey)
                .textContentType(.password)
                .autocorrectionDisabled()
            TextField("Base URL", text: $store.settings.openAiBaseUrl)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            TextField("Model", text: $store.settings.openAiModel)
                .autocorrectionDisabled()
        } footer: {
            Text("DuckDuckGo Instant Answers are always tried first (free, no key). AI is used as a fallback.")
        }
    }

    private var glassesSection: some View {
        Section("Glasses Integration") {
            HStack {
                Label("Phone IP", systemImage: "wifi")
                Spacer()
                Text(glassesServer.localIP ?? "Not available")
                    .foregroundStyle(.secondary)
                    .monospaced()
            }
            HStack {
                Label("TCP Port", systemImage: "network")
                Spacer()
                Text("8081")
                    .foregroundStyle(.secondary)
                    .monospaced()
            }
            HStack {
                Label("Connected clients", systemImage: "applewatch")
                Spacer()
                Text("\(glassesServer.clientCount)")
                    .foregroundStyle(.secondary)
            }
        } footer: {
            Text("Search results are also broadcast as JSON over TCP to any client connected on port 8081, enabling future integration with a custom glasses companion app.")
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }
            Link("Original Android Project", destination: URL(string: "https://github.com/zxy7906052/RokidSearchHelper")!)
            Link("awesome-rokid list", destination: URL(string: "https://github.com/Anezium/awesome-rokid")!)
        }
    }
}

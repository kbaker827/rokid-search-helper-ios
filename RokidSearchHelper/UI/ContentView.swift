import SwiftUI

struct ContentView: View {
    @StateObject private var settingsStore = SettingsStore()
    @StateObject private var history = SearchHistory()
    @StateObject private var glassesServer = GlassesDisplayServer()
    @StateObject private var vm: SearchViewModel

    init() {
        let store = SettingsStore()
        let hist = SearchHistory()
        let server = GlassesDisplayServer()
        _settingsStore = StateObject(wrappedValue: store)
        _history = StateObject(wrappedValue: hist)
        _glassesServer = StateObject(wrappedValue: server)
        _vm = StateObject(wrappedValue: SearchViewModel(settingsStore: store, history: hist, glassesServer: server))
    }

    var body: some View {
        TabView {
            SearchView(vm: vm)
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            HistoryView(history: history, vm: vm)
                .tabItem { Label("History", systemImage: "clock") }

            SettingsView(store: settingsStore, glassesServer: glassesServer)
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .onAppear { glassesServer.start() }
        .onDisappear { glassesServer.stop() }
    }
}

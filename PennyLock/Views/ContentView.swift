import SwiftUI

struct ContentView: View {
    @ObservedObject private var store = AppStore.shared
    @State private var showLock = false
    @State private var selection = 0

    var body: some View {
        TabView(selection: $selection) {
            OverviewView()
                .tabItem { Label(NSLocalizedString("tab.overview", comment: ""), systemImage: "house.fill") }
                .tag(0)
            TransactionsListView()
                .tabItem { Label(NSLocalizedString("tab.transactions", comment: ""), systemImage: "list.bullet") }
                .tag(1)
            AnalysisView()
                .tabItem { Label(NSLocalizedString("tab.analysis", comment: ""), systemImage: "chart.pie.fill") }
                .tag(2)
            GoalSettingsView()
                .tabItem { Label(NSLocalizedString("tab.goal", comment: ""), systemImage: "target") }
                .tag(3)
        }
        .onAppear {
            showLock = store.isLocked
            if let t = ProcessInfo.processInfo.environment["UITEST_TAB"], let idx = Int(t) {
                selection = idx
            }
        }
        .onChange(of: store.isLocked) { _, locked in
            showLock = locked
        }
        .fullScreenCover(isPresented: $showLock) {
            LockView()
        }
    }
}

import SwiftUI

struct ContentView: View {
    @ObservedObject private var store = AppStore.shared
    @State private var showLock = false

    var body: some View {
        TabView {
            OverviewView()
                .tabItem { Label(NSLocalizedString("tab.overview", comment: ""), systemImage: "house.fill") }
            TransactionsListView()
                .tabItem { Label(NSLocalizedString("tab.transactions", comment: ""), systemImage: "list.bullet") }
            AnalysisView()
                .tabItem { Label(NSLocalizedString("tab.analysis", comment: ""), systemImage: "chart.pie.fill") }
            GoalSettingsView()
                .tabItem { Label(NSLocalizedString("tab.goal", comment: ""), systemImage: "target") }
        }
        .onAppear {
            showLock = store.isLocked
        }
        .onChange(of: store.isLocked) { _, locked in
            showLock = locked
        }
        .fullScreenCover(isPresented: $showLock) {
            LockView()
        }
    }
}

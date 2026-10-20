import SwiftUI

struct ContentView: View {
    @ObservedObject private var store = AppStore.shared
    @State private var showLock = false
    @State private var selection = 0
    @State private var demoTimer: Timer?

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
            if ProcessInfo.processInfo.environment["UITEST_AUTODEMO"] == "1" {
                startAutoDemo()
            }
        }
        .onChange(of: store.isLocked) { _, locked in
            showLock = locked
        }
        .fullScreenCover(isPresented: $showLock) {
            LockView()
        }
    }

    /// 演示模式:每 4 秒自动切换一个 tab,用于录制展示视频。
    private func startAutoDemo() {
        demoTimer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            selection = (selection + 1) % 4
        }
    }
}

import SwiftUI

/// 目标页:设定月度预算上限 + 惩罚内容,查看上月结算结果。
struct GoalSettingsView: View {
    @ObservedObject private var store = AppStore.shared

    @State private var limitString = ""
    @State private var penalty = ""
    @State private var showSaved = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(NSLocalizedString("goal.limitPlaceholder", comment: ""),
                              text: $limitString)
                        .keyboardType(.decimalPad)
                } header: {
                    Text(NSLocalizedString("goal.limit", comment: ""))
                } footer: {
                    Text(NSLocalizedString("goal.limitHint", comment: ""))
                }

                Section {
                    TextEditor(text: $penalty)
                        .frame(minHeight: 100)
                } header: {
                    Text(NSLocalizedString("goal.penalty", comment: ""))
                } footer: {
                    Text(NSLocalizedString("goal.penaltyHint", comment: ""))
                }

                Section {
                    Button(NSLocalizedString("goal.save", comment: "")) { save() }
                        .frame(maxWidth: .infinity)
                }

                Section(NSLocalizedString("goal.lastResult", comment: "")) {
                    lastResultView
                }
            }
            .navigationTitle(NSLocalizedString("tab.goal", comment: ""))
            .onAppear { load() }
            .alert(NSLocalizedString("goal.saved", comment: ""), isPresented: $showSaved) {
                Button(NSLocalizedString("common.ok", comment: ""), role: .cancel) {}
            }
        }
    }

    @ViewBuilder
    private var lastResultView: some View {
        if let prev = store.previousMonthKey, let result = store.monthResults[prev], result.settled {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(result.achieved
                         ? NSLocalizedString("goal.achieved", comment: "")
                         : NSLocalizedString("goal.failed", comment: ""))
                        .fontWeight(.semibold)
                        .foregroundColor(result.achieved ? .green : .red)
                    Spacer()
                    if !result.achieved {
                        Text(String(format: NSLocalizedString("goal.overspent", comment: ""),
                                    Money.format(result.spent - result.limit)))
                            .foregroundColor(.red)
                    }
                }
                Text(String(format: NSLocalizedString("goal.resultDetail", comment: ""),
                            Money.format(result.spent), Money.format(result.limit)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(NSLocalizedString("goal.notSettled", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button(NSLocalizedString("goal.settleNow", comment: "")) {
                    store.settleLastMonth()
                }
            }
        }
    }

    private func load() {
        limitString = store.goal.monthlyLimit > 0
            ? String(format: "%.0f", store.goal.monthlyLimit)
            : ""
        penalty = store.goal.penalty
    }

    private func save() {
        let cleaned = limitString.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: "，", with: ".")
        let limit = Double(cleaned) ?? 0
        store.goal = BudgetGoal(monthlyLimit: max(0, limit), penalty: penalty)
        showSaved = true
    }
}

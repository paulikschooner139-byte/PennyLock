import SwiftUI

/// 首页:本月结余 + 预算进度 + 最近记录 + 记账入口。
struct OverviewView: View {
    @ObservedObject private var store = AppStore.shared
    @State private var showAdd = false

    private var monthKey: String { store.currentMonthKey }
    private var income: Double { store.totalIncome(monthKey: monthKey) }
    private var expense: Double { store.totalExpense(monthKey: monthKey) }
    private var balance: Double { store.balance(monthKey: monthKey) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    balanceCard
                    budgetCard
                    recentSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(NSLocalizedString("tab.overview", comment: ""))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddTransactionView()
            }
        }
    }

    // MARK: - 结余卡片

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(NSLocalizedString("overview.balance", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(Money.format(balance))
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(balance >= 0 ? .primary : .red)

            HStack {
                metric(title: NSLocalizedString("overview.income", comment: ""),
                       value: Money.format(income),
                       color: .green)
                Spacer()
                metric(title: NSLocalizedString("overview.expense", comment: ""),
                       value: Money.format(expense),
                       color: .red)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func metric(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .foregroundColor(color)
        }
    }

    // MARK: - 预算卡片

    @ViewBuilder
    private var budgetCard: some View {
        if store.goal.hasLimit {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(NSLocalizedString("overview.budget", comment: ""))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Money.format(expense)) / \(Money.format(store.goal.monthlyLimit))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                ProgressView(value: min(expense, store.goal.monthlyLimit),
                             total: store.goal.monthlyLimit)
                    .tint(expense > store.goal.monthlyLimit ? .red : .accentColor)
                if expense > store.goal.monthlyLimit {
                    Text(String(format: NSLocalizedString("overview.overspent", comment: ""),
                                Money.format(expense - store.goal.monthlyLimit)))
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }

    // MARK: - 最近记录

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("overview.recent", comment: ""))
                .font(.headline)

            let recent = Array(store.transactions(monthKey: monthKey).prefix(5))
            if recent.isEmpty {
                Text(NSLocalizedString("overview.noTransactions", comment: ""))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(recent.enumerated()), id: \.element.id) { index, tx in
                        TransactionRow(transaction: tx)
                        if index < recent.count - 1 {
                            Divider().padding(.leading, 52)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
            }
        }
    }
}

/// 单条记录行(概览页和明细页共用)。
struct TransactionRow: View {
    let transaction: Transaction

    private var category: Category {
        Categories.find(transaction.category, type: transaction.type)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundColor(transaction.type == .income ? .green : .accentColor)
                .frame(width: 40, height: 40)
                .background(Color(.tertiarySystemGroupedBackground))
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(category.localizedName)
                    .font(.body)
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(Money.signed(transaction.amount, isIncome: transaction.type == .income))
                .font(.body.weight(.medium))
                .foregroundColor(transaction.type == .income ? .green : .primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

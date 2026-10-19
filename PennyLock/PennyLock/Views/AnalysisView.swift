import SwiftUI
import Charts

/// 饼图/柱状图用的数据切片。
struct CategorySlice: Identifiable {
    var id: String { category.id }
    let category: Category
    let amount: Double
}

/// 分析页:本月 vs 上月、分类占比、每日趋势。
struct AnalysisView: View {
    @ObservedObject private var store = AppStore.shared
    private var monthKey: String { store.currentMonthKey }

    private var slices: [CategorySlice] {
        store.expenseByCategory(monthKey: monthKey).map {
            CategorySlice(category: $0.category, amount: $0.amount)
        }
    }

    private var daily: [(date: Date, amount: Double)] {
        store.dailyExpense(monthKey: monthKey)
    }

    private var thisExpense: Double { store.totalExpense(monthKey: monthKey) }
    private var prevExpense: Double {
        store.previousMonthKey.map { store.totalExpense(monthKey: $0) } ?? 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if slices.isEmpty && daily.isEmpty {
                        emptyView
                    } else {
                        compareSection
                        categorySection
                        dailySection
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(NSLocalizedString("tab.analysis", comment: ""))
        }
    }

    // MARK: - 环比

    private var compareSection: some View {
        card(title: NSLocalizedString("analysis.compare", comment: "")) {
            HStack {
                metric(NSLocalizedString("analysis.thisMonth", comment: ""), thisExpense, .red)
                Spacer()
                metric(NSLocalizedString("analysis.lastMonth", comment: ""), prevExpense, .secondary)
                Spacer()
                metric(NSLocalizedString("analysis.change", comment: ""), changePercent, changeColor)
            }
        }
    }

    private var changePercent: String {
        guard prevExpense > 0 else { return "—" }
        let pct = (thisExpense - prevExpense) / prevExpense * 100
        return String(format: "%+.1f%%", pct)
    }

    private var changeColor: Color {
        guard prevExpense > 0 else { return .secondary }
        return thisExpense > prevExpense ? .red : .green
    }

    private func metric(_ title: String, _ value: Double, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(Money.format(value)).font(.headline).foregroundColor(color)
        }
    }

    private func metric(_ title: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.headline).foregroundColor(color)
        }
    }

    // MARK: - 分类占比

    private var categorySection: some View {
        card(title: NSLocalizedString("analysis.byCategory", comment: "")) {
            Chart(slices) { slice in
                SectorMark(
                    angle: .value("amount", slice.amount),
                    innerRadius: .ratio(0.6),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("category", slice.category.localizedName))
                .cornerRadius(4)
            }
            .frame(height: 220)

            VStack(spacing: 8) {
                ForEach(slices) { slice in
                    HStack {
                        Text(slice.category.localizedName)
                            .font(.subheadline)
                        Spacer()
                        Text(Money.format(slice.amount))
                            .font(.subheadline.weight(.medium))
                    }
                }
            }
            .padding(.top, 12)
        }
    }

    // MARK: - 每日趋势

    private var dailySection: some View {
        card(title: NSLocalizedString("analysis.daily", comment: "")) {
            Chart(daily, id: \.date) { item in
                BarMark(
                    x: .value("day", item.date, unit: .day),
                    y: .value("amount", item.amount)
                )
                .foregroundStyle(Color.accentColor)
            }
            .frame(height: 200)
        }
    }

    // MARK: - 通用

    private func card(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text(NSLocalizedString("analysis.empty", comment: ""))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

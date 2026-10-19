import Foundation
import Combine

/// 数据仓库:所有记账数据、预算目标、月度结算结果,以及"惩罚锁"逻辑。
/// 全部数据仅存本机(UserDefaults + JSON),不上传、无账号。
final class AppStore: ObservableObject {
    static let shared = AppStore()

    @Published var transactions: [Transaction] = [] {
        didSet { saveTransactions() }
    }
    @Published var goal: BudgetGoal = .default {
        didSet { saveGoal() }
    }
    @Published var monthResults: [String: MonthResult] = [:] {
        didSet { saveResults() }
    }

    private let txKey = "pennyLock.transactions.v1"
    private let goalKey = "pennyLock.goal.v1"
    private let resultsKey = "pennyLock.monthResults.v1"

    init() {
        load()
        autoSettleIfNeeded()
    }

    // MARK: - 当前状态

    var currentMonthKey: String { MonthKey.current() }
    var previousMonthKey: String? { MonthKey.previous(from: currentMonthKey) }

    /// 上月是否已结算
    var isLastMonthSettled: Bool {
        guard let prev = previousMonthKey else { return false }
        return monthResults[prev]?.settled == true
    }

    /// 是否需要锁定(上月结算且未达成且惩罚未完成)
    var isLocked: Bool { pendingPenaltyResult != nil }

    /// 待完成的惩罚对应的上月结果(用于解锁页展示)
    var pendingPenaltyResult: MonthResult? {
        guard let prev = previousMonthKey,
              let result = monthResults[prev],
              result.settled, !result.achieved, !result.penaltyDone else {
            return nil
        }
        return result
    }

    // MARK: - 记账操作

    func add(_ tx: Transaction) {
        transactions.append(tx)
    }

    func update(_ tx: Transaction) {
        if let idx = transactions.firstIndex(where: { $0.id == tx.id }) {
            transactions[idx] = tx
        }
    }

    func delete(_ tx: Transaction) {
        transactions.removeAll { $0.id == tx.id }
    }

    // MARK: - 汇总

    func totalIncome(monthKey: String) -> Double {
        transactions
            .filter { $0.type == .income && MonthKey.string(from: $0.date) == monthKey }
            .reduce(0) { $0 + $1.amount }
    }

    func totalExpense(monthKey: String) -> Double {
        transactions
            .filter { $0.type == .expense && MonthKey.string(from: $0.date) == monthKey }
            .reduce(0) { $0 + $1.amount }
    }

    func balance(monthKey: String) -> Double {
        totalIncome(monthKey: monthKey) - totalExpense(monthKey: monthKey)
    }

    /// 某月按分类汇总支出,返回 (分类, 金额),按金额降序。
    func expenseByCategory(monthKey: String) -> [(category: Category, amount: Double)] {
        let expenses = transactions.filter {
            $0.type == .expense && MonthKey.string(from: $0.date) == monthKey
        }
        var map: [String: Double] = [:]
        for tx in expenses {
            map[tx.category, default: 0] += tx.amount
        }
        return map
            .map { (Categories.find($0.key, type: .expense), $0.value) }
            .sorted { $0.amount > $1.amount }
    }

    /// 某月每日支出,返回 [(日期, 金额)],按日期升序。
    func dailyExpense(monthKey: String) -> [(date: Date, amount: Double)] {
        let expenses = transactions.filter {
            $0.type == .expense && MonthKey.string(from: $0.date) == monthKey
        }
        var map: [Date: Double] = [:]
        let calendar = Calendar.current
        for tx in expenses {
            let day = calendar.startOfDay(for: tx.date)
            map[day, default: 0] += tx.amount
        }
        return map.keys.sorted().map { ($0, map[$0] ?? 0) }
    }

    /// 某月所有记录,按日期降序。
    func transactions(monthKey: String) -> [Transaction] {
        transactions
            .filter { MonthKey.string(from: $0.date) == monthKey }
            .sorted { $0.date > $1.date }
    }

    // MARK: - 结算与惩罚锁

    /// 结算某个月(把当月支出与预算上限比较)。重复结算会保留已有的解锁状态。
    func settle(monthKey: String) {
        let spent = totalExpense(monthKey: monthKey)
        let limit = goal.monthlyLimit
        let achieved = limit <= 0 || spent <= limit
        let previousPenaltyDone = monthResults[monthKey]?.penaltyDone ?? false
        monthResults[monthKey] = MonthResult(
            monthKey: monthKey,
            settled: true,
            achieved: achieved,
            spent: spent,
            limit: limit,
            penaltyDone: previousPenaltyDone
        )
    }

    /// 结算上个月(手动触发)。
    func settleLastMonth() {
        guard let prev = previousMonthKey else { return }
        settle(monthKey: prev)
    }

    /// 完成惩罚 → 解锁上月,下月恢复正常。
    func completePenalty() {
        guard let prev = previousMonthKey,
              var result = monthResults[prev] else { return }
        result.penaltyDone = true
        monthResults[prev] = result
    }

    /// 跨月后自动结算上月(如果上月有数据或设定了目标,且尚未结算)。
    func autoSettleIfNeeded() {
        guard let prev = previousMonthKey else { return }
        if monthResults[prev]?.settled == true { return }
        let hasData = totalIncome(monthKey: prev) > 0 || totalExpense(monthKey: prev) > 0
        if hasData || goal.hasLimit {
            settle(monthKey: prev)
        }
    }

    // MARK: - 持久化

    private func saveTransactions() {
        if let data = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(data, forKey: txKey)
        }
    }

    private func saveGoal() {
        if let data = try? JSONEncoder().encode(goal) {
            UserDefaults.standard.set(data, forKey: goalKey)
        }
    }

    private func saveResults() {
        if let data = try? JSONEncoder().encode(monthResults) {
            UserDefaults.standard.set(data, forKey: resultsKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: txKey),
           let value = try? JSONDecoder().decode([Transaction].self, from: data) {
            transactions = value
        }
        if let data = UserDefaults.standard.data(forKey: goalKey),
           let value = try? JSONDecoder().decode(BudgetGoal.self, from: data) {
            goal = value
        }
        if let data = UserDefaults.standard.data(forKey: resultsKey),
           let value = try? JSONDecoder().decode([String: MonthResult].self, from: data) {
            monthResults = value
        }
    }
}

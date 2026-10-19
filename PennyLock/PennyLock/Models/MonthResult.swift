import Foundation

/// 某个月的结算结果,用于驱动"惩罚锁"机制。
struct MonthResult: Codable, Identifiable, Equatable {
    var id: String { monthKey }
    var monthKey: String      // "2026-10"
    var settled: Bool         // 是否已结算
    var achieved: Bool        // 是否达成目标(支出 <= 上限)
    var spent: Double         // 当月总支出
    var limit: Double         // 结算时生效的预算上限
    var penaltyDone: Bool     // 惩罚是否已完成(解锁)

    init(monthKey: String,
         settled: Bool,
         achieved: Bool,
         spent: Double,
         limit: Double,
         penaltyDone: Bool) {
        self.monthKey = monthKey
        self.settled = settled
        self.achieved = achieved
        self.spent = spent
        self.limit = limit
        self.penaltyDone = penaltyDone
    }
}

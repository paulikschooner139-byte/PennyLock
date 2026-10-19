import Foundation

struct BudgetGoal: Codable, Equatable {
    var monthlyLimit: Double
    var penalty: String

    static let `default` = BudgetGoal(monthlyLimit: 0, penalty: "")

    var hasLimit: Bool { monthlyLimit > 0 }
}

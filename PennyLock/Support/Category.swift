import Foundation

/// 记账分类。id 是稳定 key(用于持久化),localizedName 走本地化。
struct Category: Identifiable, Hashable {
    let id: String
    let icon: String      // SF Symbol 名称
    let nameKey: String   // Localizable.strings 的 key

    var localizedName: String {
        NSLocalizedString(nameKey, comment: "")
    }
}

enum Categories {
    static let expense: [Category] = [
        Category(id: "food", icon: "fork.knife", nameKey: "cat.food"),
        Category(id: "transport", icon: "car.fill", nameKey: "cat.transport"),
        Category(id: "shopping", icon: "bag.fill", nameKey: "cat.shopping"),
        Category(id: "housing", icon: "house.fill", nameKey: "cat.housing"),
        Category(id: "entertainment", icon: "gamecontroller.fill", nameKey: "cat.entertainment"),
        Category(id: "medical", icon: "cross.case.fill", nameKey: "cat.medical"),
        Category(id: "education", icon: "book.fill", nameKey: "cat.education"),
        Category(id: "other", icon: "ellipsis.circle.fill", nameKey: "cat.other")
    ]

    static let income: [Category] = [
        Category(id: "salary", icon: "banknote.fill", nameKey: "cat.salary"),
        Category(id: "bonus", icon: "gift.fill", nameKey: "cat.bonus"),
        Category(id: "investment", icon: "chart.line.uptrend.xyaxis", nameKey: "cat.investment"),
        Category(id: "otherIncome", icon: "plus.circle.fill", nameKey: "cat.otherIncome")
    ]

    /// 根据 id 查找分类,找不到时返回一个兜底分类(理论上不会发生)。
    static func find(_ id: String, type: TransactionType) -> Category {
        let list = type == .expense ? expense : income
        return list.first { $0.id == id }
            ?? Category(id: id, icon: "questionmark.circle", nameKey: "cat.other")
    }
}

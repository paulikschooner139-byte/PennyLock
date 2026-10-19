import Foundation

/// 金额格式化:中文环境显示 ¥,其余显示 $。
enum Money {
    static func format(_ value: Double) -> String {
        let symbol = isChinese ? "¥" : "$"
        return String(format: "%@%.2f", symbol, value)
    }

    /// 带正负号的格式,用于收/支展示。
    static func signed(_ value: Double, isIncome: Bool) -> String {
        let sign = isIncome ? "+" : "-"
        let symbol = isChinese ? "¥" : "$"
        return String(format: "%@%@%.2f", sign, symbol, value)
    }

    private static var isChinese: Bool {
        Locale.preferredLanguages.first?.hasPrefix("zh") == true
    }
}

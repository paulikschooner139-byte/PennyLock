import Foundation

enum MonthKey {
    private static var formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// 当前月份 key,如 "2026-10"
    static func current() -> String {
        formatter.string(from: Date())
    }

    /// 某个日期所在月份的 key
    static func string(from date: Date) -> String {
        formatter.string(from: date)
    }

    /// 上个月的 key;返回 nil 表示无法计算(几乎不会)。
    static func previous(from monthKey: String) -> String? {
        guard let date = formatter.date(from: monthKey) else { return nil }
        guard let prev = Calendar.current.date(byAdding: .month, value: -1, to: date) else { return nil }
        return formatter.string(from: prev)
    }

    /// 把 key 转回该月 1 号的 Date(用于排序/展示)。
    static func date(from monthKey: String) -> Date? {
        formatter.date(from: monthKey)
    }
}

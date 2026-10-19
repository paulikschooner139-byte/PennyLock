import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case expense
    case income

    var localizedName: String {
        switch self {
        case .expense: return NSLocalizedString("type.expense", comment: "")
        case .income: return NSLocalizedString("type.income", comment: "")
        }
    }
}

struct Transaction: Identifiable, Codable, Hashable {
    var id: UUID
    var amount: Double
    var type: TransactionType
    var category: String
    var note: String
    var date: Date

    init(id: UUID = UUID(),
         amount: Double,
         type: TransactionType,
         category: String,
         note: String = "",
         date: Date = Date()) {
        self.id = id
        self.amount = amount
        self.type = type
        self.category = category
        self.note = note
        self.date = date
    }
}

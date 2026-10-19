import SwiftUI

/// 记账/编辑页。
struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = AppStore.shared

    var editing: Transaction?

    @State private var amountString = ""
    @State private var type: TransactionType = .expense
    @State private var categoryId = ""
    @State private var note = ""
    @State private var date = Date()
    @State private var showAlert = false

    init(editing: Transaction? = nil) {
        self.editing = editing
        if let editing {
            _amountString = State(initialValue: String(format: "%.2f", editing.amount))
            _type = State(initialValue: editing.type)
            _categoryId = State(initialValue: editing.category)
            _note = State(initialValue: editing.note)
            _date = State(initialValue: editing.date)
        }
    }

    private var categories: [Category] {
        type == .expense ? Categories.expense : Categories.income
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(NSLocalizedString("add.amount", comment: "")) {
                    HStack {
                        Text(type == .expense ? "-" : "+")
                            .font(.title2)
                            .foregroundColor(type == .expense ? .red : .green)
                        TextField("0.00", text: $amountString)
                            .keyboardType(.decimalPad)
                            .font(.title2)
                    }
                }

                Section(NSLocalizedString("add.type", comment: "")) {
                    Picker(NSLocalizedString("add.type", comment: ""), selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { t in
                            Text(t.localizedName).tag(t)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(NSLocalizedString("add.category", comment: "")) {
                    categoryGrid
                }

                Section(NSLocalizedString("add.date", comment: "")) {
                    DatePicker(NSLocalizedString("add.date", comment: ""),
                               selection: $date,
                               displayedComponents: .date)
                }

                Section(NSLocalizedString("add.note", comment: "")) {
                    TextField(NSLocalizedString("add.notePlaceholder", comment: ""), text: $note)
                }
            }
            .navigationTitle(editing == nil
                             ? NSLocalizedString("add.title", comment: "")
                             : NSLocalizedString("add.edit", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("common.cancel", comment: "")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("common.save", comment: "")) { save() }
                }
            }
            .alert(NSLocalizedString("add.invalidAmount", comment: ""), isPresented: $showAlert) {
                Button(NSLocalizedString("common.ok", comment: ""), role: .cancel) {}
            }
            .onAppear {
                if categoryId.isEmpty { categoryId = categories.first?.id ?? "" }
            }
            .onChange(of: type) { _, newType in
                categoryId = (newType == .expense ? Categories.expense : Categories.income).first?.id ?? ""
            }
        }
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72))], spacing: 12) {
            ForEach(categories) { cat in
                VStack(spacing: 6) {
                    Image(systemName: cat.icon)
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(categoryId == cat.id ? Color.accentColor : Color.gray.opacity(0.4))
                        .cornerRadius(10)
                    Text(cat.localizedName)
                        .font(.caption2)
                        .foregroundColor(categoryId == cat.id ? .primary : .secondary)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture { categoryId = cat.id }
            }
        }
        .padding(.vertical, 4)
    }

    private func save() {
        let cleaned = amountString.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: "，", with: ".")
        guard let amount = Double(cleaned), amount > 0 else {
            showAlert = true
            return
        }
        let finalCategory = categoryId.isEmpty ? (categories.first?.id ?? "other") : categoryId

        if var editing {
            editing.amount = amount
            editing.type = type
            editing.category = finalCategory
            editing.note = note
            editing.date = date
            store.update(editing)
        } else {
            store.add(Transaction(amount: amount, type: type, category: finalCategory, note: note, date: date))
        }
        dismiss()
    }
}

import SwiftUI

/// 明细页:按月份查看所有记录,支持编辑和删除。
struct TransactionsListView: View {
    @ObservedObject private var store = AppStore.shared
    @State private var selectedMonth: String = MonthKey.current()
    @State private var editingTx: Transaction?
    @State private var showAdd = false

    /// 出现过记录的月份 + 当前月,倒序。
    private var months: [String] {
        var keys = Set(store.transactions.map { MonthKey.string(from: $0.date) })
        keys.insert(MonthKey.current())
        return keys.sorted(by: >)
    }

    var body: some View {
        NavigationStack {
            Group {
                let list = store.transactions(monthKey: selectedMonth)
                if list.isEmpty {
                    emptyView
                } else {
                    List {
                        ForEach(list) { tx in
                            Button {
                                editingTx = tx
                            } label: {
                                TransactionRow(transaction: tx)
                            }
                            .buttonStyle(.plain)
                            .swipeActions {
                                Button(role: .destructive) {
                                    store.delete(tx)
                                } label: {
                                    Label(NSLocalizedString("common.delete", comment: ""),
                                          systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle(NSLocalizedString("tab.transactions", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    monthPicker
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddTransactionView()
            }
            .sheet(item: $editingTx) { tx in
                AddTransactionView(editing: tx)
            }
        }
    }

    private var monthPicker: some View {
        Menu {
            ForEach(months, id: \.self) { m in
                Button(m) { selectedMonth = m }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedMonth)
                    .fontWeight(.semibold)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text(NSLocalizedString("tx.empty", comment: ""))
                .foregroundColor(.secondary)
        }
    }
}

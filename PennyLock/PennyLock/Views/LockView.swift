import SwiftUI

/// 惩罚解锁页:上月超支后,下月进入时强制展示,完成惩罚才能继续记账。
struct LockView: View {
    @ObservedObject private var store = AppStore.shared
    @State private var result: MonthResult?
    @State private var penalty: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 56))
                .foregroundColor(.red)
                .padding(.bottom, 24)

            Text(NSLocalizedString("lock.title", comment: ""))
                .font(.largeTitle.bold())
                .padding(.bottom, 8)

            Text(NSLocalizedString("lock.subtitle", comment: ""))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let result {
                VStack(spacing: 10) {
                    row(label: NSLocalizedString("lock.budget", comment: ""),
                        value: Money.format(result.limit))
                    row(label: NSLocalizedString("lock.spent", comment: ""),
                        value: Money.format(result.spent))
                    Divider()
                    row(label: NSLocalizedString("lock.overspent", comment: ""),
                        value: Money.format(max(0, result.spent - result.limit)),
                        highlighted: true)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }

            if !penalty.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("lock.penalty", comment: ""))
                        .font(.headline)
                    Text(penalty)
                        .font(.title3.bold())
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.red.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }

            Spacer()

            Button {
                store.completePenalty()
            } label: {
                Text(NSLocalizedString("lock.complete", comment: ""))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(14)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            result = store.pendingPenaltyResult
            penalty = store.goal.penalty
        }
    }

    private func row(label: String, value: String, highlighted: Bool = false) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(highlighted ? .bold : .regular)
                .foregroundColor(highlighted ? .red : .primary)
        }
    }
}

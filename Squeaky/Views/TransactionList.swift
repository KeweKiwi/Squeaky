import SwiftUI
import SwiftData

enum TransactionFilter: String, CaseIterable {
    case all = "All"
    case income = "Income"
    case expense = "Expense"
}

struct TransactionListFlow: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]

    @State private var isSelectionMode = false
    @State private var selectedItems = Set<UUID>()
    @State private var showDeleteAlert = false
    @State private var selectedSegment: TransactionFilter = .all
    @State private var expandedSections = Set<String>()

    private var filteredTransactions: [Transaction] {
        switch selectedSegment {
        case .all:
            return transactions
        case .income:
            return transactions.filter { $0.type == .income }
        case .expense:
            return transactions.filter { $0.type == .expense }
        }
    }

    private var groupedTransactions: [(dateKey: String, items: [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            formattedSectionDate(transaction.date)
        }

        return grouped
            .map { (dateKey: $0.key, items: $0.value.sorted { $0.date > $1.date }) }
            .sorted {
                guard
                    let firstDate = $0.items.first?.date,
                    let secondDate = $1.items.first?.date
                else { return false }

                return firstDate > secondDate
            }
    }

    var body: some View {
        ZStack {
            VStack(spacing: -20) {
                headerSection

                ScrollView {
                    VStack(spacing: 10) {
                        if groupedTransactions.isEmpty {
                            ContentUnavailableView(
                                "No Transactions",
                                systemImage: "tray",
                                description: Text(emptyStateText)
                            )
                            .padding(.top, 40)
                        } else {
                            ForEach(groupedTransactions, id: \.dateKey) { group in
                                dailyGroupView(group: group)
                            }
                        }
                    }
                }
            }

            if isSelectionMode {
                trashIconButton
            }

            if showDeleteAlert {
                deleteAlertOverlay
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .task {
            SeedData.seedCategoriesIfNeeded(context: modelContext)
            BudgetSeedData.seedBudgetIfNeeded(context: modelContext)
            TransactionSeedData.seedTransactionsIfNeeded(context: modelContext)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Spacer()
                Button(isSelectionMode ? "Cancel" : "Select") {
                    withAnimation {
                        isSelectionMode.toggle()
                        selectedItems.removeAll()
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            }
            .padding(.horizontal)

            HStack(spacing: 20) {
                Image(systemName: "chevron.left")
                Text(monthYearTitle)
                    .font(.title3)
                    .fontWeight(.bold)
                Image(systemName: "chevron.right")
            }

            Picker("Filter", selection: $selectedSegment) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .onChange(of: selectedSegment) { _, _ in
                selectedItems.removeAll()
            }
        }
        .padding(.top, 50)
        .padding(.bottom, 25)
        .background(Color.themeYellow)
        .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
        .ignoresSafeArea(edges: .top)
    }

    private func dailyGroupView(group: (dateKey: String, items: [Transaction])) -> some View {
        let isExpanded = expandedSections.isEmpty || expandedSections.contains(group.dateKey)

        return VStack(spacing: 0) {
            HStack {
                Text(group.dateKey)
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            }
            .padding()
            .background(Color.themePurple)
            .onTapGesture {
                toggleSection(group.dateKey)
            }

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(group.items, id: \.id) { item in
                        HStack {
                            if isSelectionMode {
                                Image(systemName: selectedItems.contains(item.id) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selectedItems.contains(item.id) ? .black : .gray)
                                    .onTapGesture {
                                        if selectedItems.contains(item.id) {
                                            selectedItems.remove(item.id)
                                        } else {
                                            selectedItems.insert(item.id)
                                        }
                                    }
                            }

                            ZStack {
                                Circle()
                                    .fill(categoryColor(for: item).opacity(0.2))
                                    .frame(width: 35, height: 35)
                                Text(categoryEmoji(for: item))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.body)

                                if let note = item.note, !note.isEmpty {
                                    Text(note)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Text(currency(item.amount))
                                .fontWeight(.semibold)
                        }
                        .padding()

                        Divider().padding(.leading, isSelectionMode ? 50 : 20)
                    }

                    groupFooter(for: group.items)
                        .padding()
                }
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }

    @ViewBuilder
    private func groupFooter(for items: [Transaction]) -> some View {
        switch selectedSegment {
        case .all:
            HStack {
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Total Income")
                            .foregroundColor(.gray)
                        Text(currency(totalIncome(for: items)))
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }

                    HStack(spacing: 8) {
                        Text("Total Expense")
                            .foregroundColor(.gray)
                        Text(currency(totalExpense(for: items)))
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
            }

        case .income:
            HStack {
                Spacer()
                Text("Total Income")
                    .foregroundColor(.gray)
                Text(currency(totalIncome(for: items)))
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }

        case .expense:
            HStack {
                Spacer()
                Text("Total Expense")
                    .foregroundColor(.gray)
                Text(currency(totalExpense(for: items)))
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
        }
    }

    private var trashIconButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 30)
                .padding(.bottom, 100)
            }
        }
    }

    private var deleteAlertOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Are you sure you want to delete?")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                HStack(spacing: 15) {
                    Button("No") {
                        showDeleteAlert = false
                        isSelectionMode = false
                        selectedItems.removeAll()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    .foregroundColor(.black)

                    Button("Yes") {
                        deleteAction()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                    .foregroundColor(.white)
                }
            }
            .padding(25)
            .background(Color.themeYellow)
            .cornerRadius(25)
            .padding(.horizontal, 40)
        }
    }

    private var emptyStateText: String {
        switch selectedSegment {
        case .all:
            return "No transactions yet."
        case .income:
            return "No income transactions yet."
        case .expense:
            return "No expense transactions yet."
        }
    }

    private var monthYearTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: .now)
    }

    private func formattedSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d"
        return formatter.string(from: date)
    }

    private func totalIncome(for items: [Transaction]) -> Decimal {
        items
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    private func totalExpense(for items: [Transaction]) -> Decimal {
        items
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    private func currency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "Rp0"
    }

    private func categoryEmoji(for transaction: Transaction) -> String {
        switch transaction.category?.name.lowercased() {
        case "food": return "🍔"
        case "clothing": return "👚"
        case "transport": return "🚗"
        case "beauty": return "💄"
        case "entertainment": return "🎬"
        case "gift": return "🎁"
        case "medical": return "🩺"
        case "debt": return "💳"
        case "daily": return "🛒"
        case "salary": return "💰"
        case "allowance": return "💸"
        case "bonus": return "🎉"
        case "freelance": return "🧑‍💻"
        default: return "🧾"
        }
    }

    private func categoryColor(for transaction: Transaction) -> Color {
        switch transaction.category?.name.lowercased() {
        case "food": return .orange
        case "clothing": return .purple
        case "transport": return .blue
        case "beauty": return .pink
        case "entertainment": return .indigo
        case "gift": return .red
        case "medical": return .green
        case "debt": return .gray
        case "daily": return .yellow
        case "salary", "allowance", "bonus", "freelance": return .green
        default: return .gray
        }
    }

    private func toggleSection(_ key: String) {
        if expandedSections.contains(key) {
            expandedSections.remove(key)
        } else {
            expandedSections.insert(key)
        }
    }

    private func deleteAction() {
        let itemsToDelete = transactions.filter { selectedItems.contains($0.id) }

        for item in itemsToDelete {
            modelContext.delete(item)
        }

        try? modelContext.save()

        showDeleteAlert = false
        isSelectionMode = false
        selectedItems.removeAll()
    }
}

extension Color {
    static let themeYellow = Color(red: 1.0, green: 0.98, blue: 0.88)
    static let themePurple = Color(red: 0.92, green: 0.85, blue: 0.98)
    static let themeGray = Color(red: 0.95, green: 0.95, blue: 0.95)
}

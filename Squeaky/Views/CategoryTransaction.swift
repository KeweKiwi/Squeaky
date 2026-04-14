//
//  CategoryTransaction.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 13/04/26.
//

import SwiftUI
import SwiftData

struct CategoryTransaction: View {
    let expenseCategory: ExpenseCategory

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]

    @State private var expandedSections = Set<String>()
    @State private var selectedMonth: String = Calendar.current.monthSymbols[Calendar.current.component(.month, from: .now) - 1]
    @State private var selectedYear: Int = Calendar.current.component(.year, from: .now)
    @State private var showDatePicker = false

    private let months = Calendar.current.monthSymbols
    private let years = Array(2020...2030)

    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current

        guard let selectedMonthIndex = months.firstIndex(of: selectedMonth) else {
            return []
        }

        let targetMonth = selectedMonthIndex + 1

        return transactions.filter { transaction in
            transaction.type == .expense &&
            transaction.category?.name.localizedCaseInsensitiveCompare(expenseCategory.name) == .orderedSame &&
            calendar.component(.month, from: transaction.date) == targetMonth &&
            calendar.component(.year, from: transaction.date) == selectedYear
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
                else {
                    return false
                }

                return firstDate > secondDate
            }
    }

    private var totalExpense: Decimal {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        
        VStack(spacing: 0) {
            headerSection

            VStack(spacing: 0) {
                categoryName
                    .padding(.horizontal)
                    .padding(.bottom, 30)

                summaryCard
                    .padding(.horizontal)
                    .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 12) {

                        if groupedTransactions.isEmpty {
                            ContentUnavailableView(
                                "No Transactions",
                                systemImage: "tray",
                                description: Text("There are no expense transactions in this category for \(selectedMonth) \(selectedYear).")
                            )
                            .padding(.top, 40)
                        } else {
                            ForEach(groupedTransactions, id: \.dateKey) { group in
                                dailyGroupView(group: group)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            expandAllSections()
        }
        .onChange(of: selectedMonth) { _, _ in
            expandAllSections()
        }
        .onChange(of: selectedYear) { _, _ in
            expandAllSections()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDatePicker) {
            datePickerModal
        }
    }
    
    private var categoryName: some View{
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(expenseCategory.color.opacity(0.18))
                    .frame(width: 44, height: 44)

                Text(expenseCategory.icon)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(expenseCategory.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("Category Expense")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
    }
    
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            
            HStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        changeMonth(by: -1)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding(6)
                }

                Button {
                    showDatePicker = true
                } label: {
                    Text(selectedMonth + " " + String(selectedYear))
                        .font(.title3.weight(.bold))
                        .foregroundColor(.black)
                }

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        changeMonth(by: 1)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .padding(6)
                }
            }
        }
        .padding(.top, 88)
        .padding(.bottom, 32)
        .padding(.horizontal, 150)
        .background(Color.themeYellow)
        .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
        .ignoresSafeArea()
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Expense")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(currency(totalExpense))
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                }

                Spacer()

                Text("\(filteredTransactions.count) transaction\(filteredTransactions.count == 1 ? "" : "s")")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private var datePickerModal: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 0) {
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text(month).tag(month)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Select Month and Year")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showDatePicker = false
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }

    // Row expenses each day
    private func dailyGroupView(group: (dateKey: String, items: [Transaction])) -> some View {
        let isExpanded = expandedSections.contains(group.dateKey)

        return VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    toggleSection(group.dateKey)
                }
            } label: {
                HStack {
                    Text(group.dateKey)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.themePurple)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(group.items, id: \.id) { item in
                        transactionRow(for: item)

                        if item.id != group.items.last?.id {
                            Divider()
                                .padding(.leading, 68)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
        .padding(.horizontal)
    }

    // Transaction
    private func transactionRow(for transaction: Transaction) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(expenseCategory.color.opacity(0.18))
                    .frame(width: 40, height: 40)

                Text(expenseCategory.icon)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.body)

                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(currency(transaction.amount))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(formattedTime(transaction.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }

    private func formattedSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d"
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func currency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "Rp0"
    }

    private func toggleSection(_ key: String) {
        if expandedSections.contains(key) {
            expandedSections.remove(key)
        } else {
            expandedSections.insert(key)
        }
    }

    private func expandAllSections() {
        expandedSections = Set(groupedTransactions.map { $0.dateKey })
    }

    private func changeMonth(by amount: Int) {
        guard let currentIndex = months.firstIndex(of: selectedMonth) else {
            return
        }

        var newIndex = currentIndex + amount

        if newIndex > 11 {
            newIndex = 0
            selectedYear += 1
        } else if newIndex < 0 {
            newIndex = 11
            selectedYear -= 1
        }

        selectedMonth = months[newIndex]
    }
}

#Preview {
    NavigationStack {
        CategoryTransaction(
            expenseCategory: ExpenseCategory(
                name: "Food",
                amount: 250000,
                color: .orange,
                icon: "🍔"
            )
        )
    }
    .modelContainer(for: [Category.self, Transaction.self], inMemory: true)
}

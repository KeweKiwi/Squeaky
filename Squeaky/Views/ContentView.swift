//
//  ContentView.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]

    @Query
    private var budgets: [MonthlyBudget]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                summarySection

                if transactions.isEmpty {
                    ContentUnavailableView(
                        "No Transactions Yet",
                        systemImage: "tray",
                        description: Text("Transactions from your shortcut or app will appear here.")
                    )
                } else {
                    List {
                        ForEach(transactions) { transaction in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(transaction.title)
                                        .font(.headline)

                                    Spacer()

                                    Text(currency(transaction.amount))
                                        .font(.subheadline)
                                        .foregroundStyle(
                                            transaction.type == .income ? .green : .red
                                        )
                                }

                                Text("\(transaction.category?.name ?? "-") • \(transaction.type.rawValue.capitalized)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text(transaction.date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteTransactions)
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Squeaky")
        }
        .task {
            SeedData.seedCategoriesIfNeeded(context: modelContext)
            BudgetSeedData.seedBudgetIfNeeded(context: modelContext)
            TransactionSeedData.seedTransactionsIfNeeded(context: modelContext)
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Balance: \(currency(balance))")
                .font(.title3)
                .bold()

            Text("Income: \(currency(totalIncome))")
            Text("Expense: \(currency(totalExpense))")
            Text("Budget: \(currency(currentBudget))")
            Text("Cortisol: \(cortisolStatus)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var totalIncome: Decimal {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    private var totalExpense: Decimal {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    private var balance: Decimal {
        totalIncome - totalExpense
    }

    private var currentBudget: Decimal {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: .now)
        let year = calendar.component(.year, from: .now)

        return Decimal(budgets.first(where: { $0.month == month && $0.year == year })?.budgetAmount ?? 0)
    }

    private var cortisolStatus: String {
        guard currentBudget > 0 else { return "No Budget" }

        let expense = NSDecimalNumber(decimal: totalExpense).doubleValue
        let budget = NSDecimalNumber(decimal: currentBudget).doubleValue
        let ratio = expense / budget

        if ratio < 0.7 {
            return "Low"
        } else if ratio <= 1.0 {
            return "Medium"
        } else {
            return "High"
        }
    }

    private func deleteTransactions(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(transactions[index])
        }

        try? modelContext.save()
    }

    private func currency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "Rp0"
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [
                Category.self,
                Transaction.self,
                MonthlyBudget.self,
                SavingGoal.self,
                UserStats.self
            ],
            inMemory: true
        )
}

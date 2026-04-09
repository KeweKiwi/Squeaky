//
//  OverviewView.swift
//  Squeaky
//
//  Created by Nayla Abel Sabathyani on 06/04/26.
//

import SwiftUI
import SwiftData
import Charts
import AppIntents

struct OverviewView: View {
    
    @State private var isCensored: Bool = false

    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]

    @Query
    private var budgets: [MonthlyBudget]

    @Query
    private var savingGoals: [SavingGoal]

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

    private var currentMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        return transactions.filter {
            calendar.isDate($0.date, equalTo: .now, toGranularity: .month) &&
            calendar.isDate($0.date, equalTo: .now, toGranularity: .year)
        }
    }

    private var currentMonthExpense: Decimal {
        currentMonthTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    private var currentMonthBudget: Decimal {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: .now)
        let currentYear = calendar.component(.year, from: .now)

        let budget = budgets.first(where: {
            $0.month == currentMonth && $0.year == currentYear
        })?.budgetAmount ?? 0

        return Decimal(budget)
    }

    private var spentRatio: Double {
        guard currentMonthBudget > 0 else { return 0 }
        let spent = NSDecimalNumber(decimal: currentMonthExpense).doubleValue
        let budget = NSDecimalNumber(decimal: currentMonthBudget).doubleValue
        return min(spent / budget, 1.0)
    }

    private var chartData: [ExpenseCategory] {
        let grouped = Dictionary(grouping: currentMonthTransactions.filter { $0.type == .expense }) {
            $0.category?.name ?? "Other"
        }

        let palette: [Color] = [
            .yellow, .teal, .orange, .pink, .purple, .blue, .green, .red, .indigo, .mint
        ]

        let sorted = grouped
            .map { key, value in
                ExpenseCategory(
                    name: key,
                    amount: value.reduce(0) { $0 + NSDecimalNumber(decimal: $1.amount).doubleValue },
                    color: palette[abs(key.hashValue) % palette.count],
                    icon: categoryEmoji(for: key)
                )
            }
            .sorted { $0.amount > $1.amount }

        return sorted
    }

    private var sortedGoals: [SavingGoal] {
        savingGoals.sorted {
            progress(of: $0) > progress(of: $1)
        }
    }

    var body: some View {
        
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("What’s your money up to?")
                            .font(.system(size: 32))
                            .bold()
                        Spacer()
                        NavigationLink(destination:MonthlyRecapView()) {
                            Image("Fitur")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 50)
                        }
                    }
                    
                    HStack{
                        
                        Text("Overview")
                            .font(.title2)
                            .bold()
                        Spacer()
                        Button(action: {
                            isCensored.toggle()
                        }) {
                            Image(systemName: isCensored ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .font(.title3)
                        }
                    }
                }

                HStack(spacing: 5) {
                    summaryCard(
                        icon: "wallet.bifold.fill",
                        title: "Balance",
                        value: (isCensored ? "*** ***" : currency(balance))
                    )

                    summaryCard(
                        icon: "arrowshape.up.circle.fill",
                        title: "Income",
                        value: (isCensored ? "*** ***" : currency(totalIncome))
                    )

                    summaryCard(
                        icon: "minus.circle.fill",
                        title: "Expense",
                        value: (isCensored ? "*** ***" : currency(totalExpense))
                    )
                }

                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Budget this Month")
                            .font(.body)
                            .bold()

                        Spacer()

                        NavigationLink(destination: Text("Edit Budget Page")) {
                            Image(systemName: "square.and.pencil")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }

                    ProgressView(
                        value: NSDecimalNumber(decimal: currentMonthExpense).doubleValue,
                        total: max(NSDecimalNumber(decimal: currentMonthBudget).doubleValue, 1)
                    )
                    .scaleEffect(x: 1, y: 3, anchor: .center)
                    .tint(.orange)
                    Text("\(currency(currentMonthExpense)) / \(currency(currentMonthBudget))")
                        .font(.headline)
                }

                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))

                        VStack {
                            Text("Squeaky level:")
                                .font(.footnote)
                                .bold()
                                .padding(.horizontal, 16)
                                .padding(.top, 1)

                            ZStack {
                                Image("Meter")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .padding(.top, 55)

                                Image("Needle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 60)
                                    .rotationEffect(.degrees(-90 + (spentRatio * 180)), anchor: .bottom)
                                    .offset(y: 40)

                                Image("Pet lvl 1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 90)
                                    .offset(y: -20)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)

                    NavigationLink(destination: Text("Bigger Pie Chart")) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)

                            if chartData.isEmpty {
                                Text("No expense data")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                Chart(chartData) { expense in
                                    SectorMark(
                                        angle: .value("Spent", expense.amount),
                                        innerRadius: .ratio(0.0),
                                        angularInset: 0.5
                                    )
                                    .foregroundStyle(expense.color)
                                    .annotation(position: .overlay) {
                                        Text(expense.icon)
                                            .font(.title2)
                                    }
                                }
                                .padding(10)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Saving goals 🥳")
                            .font(.body)
                            .bold()

                        Spacer()

                        NavigationLink(destination: Text("Add Saving Goal Page")) {
                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }

                    if sortedGoals.isEmpty {
                        Text("No saving goals yet.")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.7))
                    } else {
                        ForEach(sortedGoals) { goal in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(goal.title)
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.black)

                                ProgressView(
                                    value: NSDecimalNumber(decimal: goal.currentAmount).doubleValue,
                                    total: max(NSDecimalNumber(decimal: goal.targetAmount).doubleValue, 1)
                                )
                                .tint(.black)
                                .scaleEffect(x: 1, y: 3, anchor: .center)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .padding(20)
                .background(Color.yellow)
                .cornerRadius(16)
            }
            .padding(20)
        }
    }

    private func summaryCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.black)

                Text(title)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.black)
            }

            Text(value)
                .font(.title3)
                .bold()
                .foregroundColor(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(Color.yellow)
        .cornerRadius(16)
    }

    private func currency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","

        let numberString = formatter.string(from: NSDecimalNumber(decimal: value)) ?? "0"
        return "Rp\(numberString)"
    }

    private func progress(of goal: SavingGoal) -> Double {
        let current = NSDecimalNumber(decimal: goal.currentAmount).doubleValue
        let target = NSDecimalNumber(decimal: goal.targetAmount).doubleValue
        guard target > 0 else { return 0 }
        return current / target
    }

    private func categoryEmoji(for name: String) -> String {
        switch name.lowercased() {
        case "food": return "🍔"
        case "entertainment": return "🎬"
        case "social": return "🥂"
        case "transport": return "🚕"
        case "gift": return "🎁"
        case "beauty": return "💄"
        case "medical": return "🩺"
        case "debt": return "💳"
        case "daily": return "🛒"
        case "salary": return "💰"
        case "allowance": return "💸"
        case "bonus": return "🎉"
        default: return "🧾"
        }
    }
}

struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
    let icon: String
}

#Preview {
    OverviewView()
        .modelContainer(
            for: [
                Category.self,
                Transaction.self,
                MonthlyBudget.self,
                SavingGoal.self
            ],
            inMemory: true
        )
}

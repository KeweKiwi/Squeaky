import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Category.name) private var categories: [Category]

    @FocusState private var focusedField: Field?

    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategoryName: String = ""
    @State private var note: String = ""
    @State private var amountText: String = ""
    @State private var selectedDate: Date = .now
    @State private var showDatePickerSheet = false

    enum Field {
        case note
        case amount
    }

    private let expenseCategoryOrder = [
        "Education", "Food", "Transport", "Gift",
        "Beauty", "Clothes", "Social", "Medical",
        "Debt", "Entertainment", "Daily", "Other"
    ]

    private let incomeCategoryOrder = [
        "Salary", "Allowance", "Bonus", "Freelance", "Other"
    ]

    private var filteredCategories: [Category] {
        let targetType: CategoryType = selectedType == .expense ? .expense : .income
        let base = categories.filter { $0.type == targetType }
        let order = selectedType == .expense ? expenseCategoryOrder : incomeCategoryOrder

        return base.sorted { first, second in
            let firstIndex = order.firstIndex(of: first.name) ?? Int.max
            let secondIndex = order.firstIndex(of: second.name) ?? Int.max
            return firstIndex < secondIndex
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                segmentedTypeSwitcher
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 20) {
                        categoryGrid
                            .padding(.top, 24)

                        Spacer(minLength: 260)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }

            inputPanel
        }
        .onAppear {
            syncDefaultCategory()
            focusedField = .note
        }
        .sheet(isPresented: $showDatePickerSheet) {
            NavigationStack {
                VStack {
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()

                    Spacer()
                }
                .navigationTitle("Choose Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showDatePickerSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var segmentedTypeSwitcher: some View {
        HStack(spacing: 0) {
            segmentButton(title: "Expense", type: .expense)
            segmentButton(title: "Income", type: .income)
        }
        .padding(4)
        .background(Color.gray.opacity(0.15))
        .clipShape(Capsule())
    }

    private func segmentButton(title: String, type: TransactionType) -> some View {
        let isSelected = selectedType == type

        return Button {
            selectedType = type
            syncDefaultCategory()
        } label: {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.black : Color.clear)
                .clipShape(Capsule())
        }
    }

    private var categoryGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 18), count: 4)

        return LazyVGrid(columns: columns, spacing: 26) {
            ForEach(filteredCategories, id: \.id) { category in
                Button {
                    selectedCategoryName = category.name
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(selectedCategoryName == category.name ? Color.black.opacity(0.08) : Color.clear)
                                .frame(width: 60, height: 60)

                            Text(categoryEmoji(for: category.name))
                                .font(.system(size: 36))
                        }

                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var inputPanel: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                TextField("note", text: $note)
                    .focused($focusedField, equals: .note)
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())

                TextField("Rp.", text: $amountText)
                    .focused($focusedField, equals: .amount)
                    .keyboardType(.numberPad)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                Button {
                    showDatePickerSheet = true
                } label: {
                    Text(todayLabel)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .frame(height: 40)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                }

                Button {
                    saveTransaction()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(canSave ? Color.black : Color.gray.opacity(0.5))
                        .clipShape(Circle())
                }
                .disabled(!canSave)

                Spacer()
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 28)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.themeYellow)
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }

    private var todayLabel: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter.string(from: selectedDate)
        }
    }

    private var canSave: Bool {
        !selectedCategoryName.isEmpty &&
        !amountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Decimal(string: cleanedAmount) != nil
    }

    private var cleanedAmount: String {
        amountText
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func syncDefaultCategory() {
        if let first = filteredCategories.first {
            selectedCategoryName = first.name
        } else {
            selectedCategoryName = ""
        }
    }

    private func saveTransaction() {
        guard let amount = Decimal(string: cleanedAmount), amount > 0 else { return }

        let selectedCategory = filteredCategories.first { $0.name == selectedCategoryName }

        let transaction = Transaction(
            title: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? selectedCategoryName : note,
            amount: amount,
            type: selectedType,
            date: selectedDate,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note,
            category: selectedCategory
        )

        modelContext.insert(transaction)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save transaction: \(error)")
        }
    }

    private func categoryEmoji(for name: String) -> String {
        switch name.lowercased() {
        case "education": return "📚"
        case "food": return "🍔"
        case "transport": return "🚕"
        case "gift": return "🎁"
        case "beauty": return "💄"
        case "clothes", "clothing": return "👚"
        case "social": return "🥂"
        case "medical": return "🩺"
        case "debt": return "💳"
        case "entertainment": return "🎬"
        case "daily": return "🛒"
        case "other": return "➕"
        case "salary": return "💰"
        case "allowance": return "💸"
        case "bonus": return "🎉"
        case "freelance": return "🧑‍💻"
        default: return "🧾"
        }
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(for: [Category.self, Transaction.self], inMemory: true)
}

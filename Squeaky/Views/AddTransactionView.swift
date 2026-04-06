//
//  AddTransactionView.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let draft: ShortcutTransactionDraft

    @State private var title: String
    @State private var amount: Double
    @State private var selectedType: String
    @State private var selectedCategory: String
    @State private var date: Date
    @State private var note: String = ""

    init(draft: ShortcutTransactionDraft) {
        self.draft = draft
        _title = State(initialValue: draft.title)
        _amount = State(initialValue: draft.amount)
        _selectedType = State(initialValue: draft.type)
        _selectedCategory = State(initialValue: draft.category)
        _date = State(initialValue: draft.date)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)

                TextField("Amount", value: $amount, format: .number)

                Picker("Type", selection: $selectedType) {
                    Text("Income").tag("income")
                    Text("Expense").tag("expense")
                }

                Picker("Category", selection: $selectedCategory) {
                    Text("Food").tag("food")
                    Text("Clothing").tag("clothing")
                    Text("Transport").tag("transport")
                    Text("Beauty").tag("beauty")
                    Text("Entertainment").tag("entertainment")
                    Text("Gift").tag("gift")
                    Text("Medical").tag("medical")
                    Text("Debt").tag("debt")
                    Text("Daily").tag("daily")
                    Text("Salary").tag("salary")
                    Text("Allowance").tag("allowance")
                    Text("Bonus").tag("bonus")
                    Text("Other").tag("other")
                }

                DatePicker("Date", selection: $date, displayedComponents: .date)

                TextField("Note", text: $note)
            }
            .navigationTitle("Add Transaction")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                }
            }
        }
    }

    private func saveTransaction() {
        let transactionType: TransactionType = selectedType == "income" ? .income : .expense
        let categoryType: CategoryType = selectedType == "income" ? .income : .expense

        let fetch = FetchDescriptor<Category>()
        let existingCategories = (try? modelContext.fetch(fetch)) ?? []

        let category = existingCategories.first {
            $0.name.lowercased() == selectedCategory.lowercased()
        } ?? {
            let newCategory = Category(
                id: UUID(),
                name: selectedCategory.capitalized,
                type: categoryType
            )
            modelContext.insert(newCategory)
            return newCategory
        }()

        let transaction = Transaction(
            id: UUID(),
            title: title,
            amount: Decimal(amount),
            type: transactionType,
            date: date,
            note: note.isEmpty ? nil : note,
            category: category
        )

        modelContext.insert(transaction)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save transaction: \(error)")
        }
    }
}

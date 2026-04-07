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

    @Query(sort: \Category.name) private var categories: [Category]

    @State private var title: String = ""
    @State private var amount: Double = 0
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategoryName: String = ""
    @State private var date: Date = .now
    @State private var note: String = ""

    private var filteredCategories: [Category] {
        categories.filter { $0.type == categoryTypeForSelection || $0.name == "Other" }
    }

    private var categoryTypeForSelection: CategoryType {
        selectedType == .income ? .income : .expense
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)

                TextField("Amount", value: $amount, format: .number)
                    .keyboardType(.decimalPad)

                Picker("Type", selection: $selectedType) {
                    Text("Income").tag(TransactionType.income)
                    Text("Expense").tag(TransactionType.expense)
                }
                .onChange(of: selectedType) { _, _ in
                    selectedCategoryName = ""
                }

                Picker("Category", selection: $selectedCategoryName) {
                    Text("Select Category").tag("")

                    ForEach(filteredCategories, id: \.id) { category in
                        Text(category.name).tag(category.name)
                    }
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
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || amount <= 0 || selectedCategoryName.isEmpty)
                }
            }
            .onAppear {
                if selectedCategoryName.isEmpty, let first = filteredCategories.first {
                    selectedCategoryName = first.name
                }
            }
        }
    }

    private func saveTransaction() {
        let selectedCategory = categories.first {
            $0.name == selectedCategoryName && $0.type == categoryTypeForSelection
        }

        let transaction = Transaction(
            id: UUID(),
            title: title,
            amount: Decimal(amount),
            type: selectedType,
            date: date,
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
}

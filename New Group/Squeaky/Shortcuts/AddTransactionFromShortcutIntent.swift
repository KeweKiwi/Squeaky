//
//  AddTransactionFromShortcutIntent.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import AppIntents
import SwiftData
import Foundation

struct AddTransactionFromShortcutIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Transaction"
    static var description = IntentDescription("Save a transaction directly into Squeaky.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Transaction Name")
    var titleText: String

    @Parameter(title: "Amount")
    var amount: Double

    @Parameter(title: "Type")
    var type: ShortcutTransactionType

    @Parameter(title: "Category")
    var category: ShortcutCategoryOption

    @Parameter(title: "Date")
    var date: Date

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$type) named \(\.$titleText), amount \(\.$amount), category \(\.$category), on \(\.$date)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = SharedModelContainer.container.mainContext

        let transactionType: TransactionType = (type == .income) ? .income : .expense
        let categoryType: CategoryType = (type == .income) ? .income : .expense
        let categoryName = category.rawValue.capitalized

        let descriptor = FetchDescriptor<Category>()
        let existingCategories = try context.fetch(descriptor)

        let finalCategory = existingCategories.first {
            $0.name.lowercased() == categoryName.lowercased()
        } ?? {
            let newCategory = Category(
                id: UUID(),
                name: categoryName,
                type: categoryType
            )
            context.insert(newCategory)
            return newCategory
        }()

        let transaction = Transaction(
            id: UUID(),
            title: titleText,
            amount: Decimal(amount),
            type: transactionType,
            date: date,
            note: nil,
            category: finalCategory
        )

        context.insert(transaction)
        try context.save()

        return .result(dialog: "Transaction saved to Squeaky.")
    }
}

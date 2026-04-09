//
//  TransactionSeedData.swift
//  Squeaky
//
//  Created by Kevin William Faith on 06/04/26.
//

import Foundation
import SwiftData

enum TransactionSeedData {
    static func seedTransactionsIfNeeded(context: ModelContext) {
        let transactionDescriptor = FetchDescriptor<Transaction>()
        guard let existingTransactions = try? context.fetch(transactionDescriptor),
              existingTransactions.isEmpty else { return }

        
        let categoryDescriptor = FetchDescriptor<Category>()
        guard let categories = try? context.fetch(categoryDescriptor) else { return }

        
        let food = categories.first(where: { $0.name == "Food" && $0.type == .expense })
        let clothing = categories.first(where: { $0.name == "Clothing" && $0.type == .expense })
        let transport = categories.first(where: { $0.name == "Transport" && $0.type == .expense })
        let entertainment = categories.first(where: { $0.name == "Entertainment" && $0.type == .expense })
        let allowance = categories.first(where: { $0.name == "Allowance" && $0.type == .income })
        let salary = categories.first(where: { $0.name == "Salary" && $0.type == .income })

        let sampleTransactions = [
            Transaction(
                id: UUID(),
                title: "Mie Ayam",
                amount: 25000,
                type: .expense,
                date: .now,
                note: "Lunch",
                category: food
            ),
            Transaction(
                id: UUID(),
                title: "GoRide",
                amount: 18000,
                type: .expense,
                date: .now.addingTimeInterval(-86400),
                note: "To campus",
                category: transport
            ),
            Transaction(
                id: UUID(),
                title: "Movie",
                amount: 50000,
                type: .expense,
                date: .now.addingTimeInterval(-172800),
                note: nil,
                category: entertainment
            ),
            Transaction(
                id: UUID(),
                title: "Uniqlo T-Shirt",
                amount: 99000,
                type: .expense,
                date: .now.addingTimeInterval(-259200),
                note: nil,
                category: clothing
            ),
            Transaction(
                id: UUID(),
                title: "Monthly Allowance",
                amount: 1500000,
                type: .income,
                date: .now.addingTimeInterval(-345600),
                note: nil,
                category: allowance
            ),
            Transaction(
                id: UUID(),
                title: "Part-time Salary",
                amount: 500000,
                type: .income,
                date: .now.addingTimeInterval(-432000),
                note: nil,
                category: salary
            )
        ]

        for transaction in sampleTransactions {
            context.insert(transaction)
        }

        try? context.save()
    }
}

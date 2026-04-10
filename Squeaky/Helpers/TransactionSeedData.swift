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
        let clothing = categories.first(where: { $0.name == "Clothes" && $0.type == .expense })
        let transport = categories.first(where: { $0.name == "Transport" && $0.type == .expense })
        let entertainment = categories.first(where: { $0.name == "Entertainment" && $0.type == .expense })
        let allowance = categories.first(where: { $0.name == "Allowance" && $0.type == .income })
        let salary = categories.first(where: { $0.name == "Salary" && $0.type == .income })

        let calendar = Calendar.current
        let now = Date()

        let currentMonth1 = calendar.date(byAdding: .day, value: -2, to: now) ?? now
        let currentMonth2 = calendar.date(byAdding: .day, value: -8, to: now) ?? now

        let lastMonth1 = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        let lastMonth2 = calendar.date(byAdding: .day, value: -5, to: lastMonth1) ?? lastMonth1

        let twoMonthsAgo1 = calendar.date(byAdding: .month, value: -2, to: now) ?? now
        let twoMonthsAgo2 = calendar.date(byAdding: .day, value: -10, to: twoMonthsAgo1) ?? twoMonthsAgo1

        let sampleTransactions = [
            // Bulan ini
            Transaction(
                id: UUID(),
                title: "Mie Ayam",
                amount: 25000,
                type: .expense,
                date: currentMonth1,
                note: "Lunch",
                category: food
            ),
            Transaction(
                id: UUID(),
                title: "Monthly Allowance",
                amount: 1500000,
                type: .income,
                date: currentMonth2,
                note: nil,
                category: allowance
            ),
            
            Transaction(
                id: UUID(),
                title: "Nonton Frozen",
                amount: 100000,
                type: .expense,
                date: currentMonth1,
                note: "premiere",
                category: entertainment
            ),

            // 1 bulan lalu
            Transaction(
                id: UUID(),
                title: "GoRide",
                amount: 18000,
                type: .expense,
                date: lastMonth1,
                note: "To campus",
                category: transport
            ),
            Transaction(
                id: UUID(),
                title: "Part-time Salary",
                amount: 500000,
                type: .income,
                date: lastMonth2,
                note: nil,
                category: salary
            ),

            // 2 bulan lalu
            Transaction(
                id: UUID(),
                title: "Movie",
                amount: 50000,
                type: .expense,
                date: twoMonthsAgo1,
                note: nil,
                category: entertainment
            ),
            Transaction(
                id: UUID(),
                title: "T-Shirt",
                amount: 99000,
                type: .expense,
                date: twoMonthsAgo2,
                note: nil,
                category: clothing
            )
        ]

        for transaction in sampleTransactions {
            context.insert(transaction)
        }

        try? context.save()
    }
}

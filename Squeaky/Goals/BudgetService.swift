//
//  BudgetService.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 08/04/26.
//

import Foundation
import SwiftData

struct BudgetService {
    static func currentBudget(from budgets: [MonthlyBudget]) -> MonthlyBudget? {
        let currentMonth = Calendar.current.component(.month, from: .now)
        let currentYear = Calendar.current.component(.year, from: .now)

        return budgets.first(where: {
            $0.month == currentMonth && $0.year == currentYear
        })
    }
    
    static func addProgress(
        amount: Double,
        context: ModelContext,
        budgets: [MonthlyBudget]
    ) -> Bool {
        guard let budget = currentBudget(from: budgets) else { return false }

        // Prevent minus
        guard budget.budgetAmount >= amount else { return false }

        budget.budgetAmount -= amount

        try? context.save()
        
        return true
    }

    static func refundProgress(
        amount: Double,
        context: ModelContext,
        budgets: [MonthlyBudget]
    ) {
        guard let budget = currentBudget(from: budgets) else { return }

        budget.budgetAmount += amount
        try? context.save()
    }
}

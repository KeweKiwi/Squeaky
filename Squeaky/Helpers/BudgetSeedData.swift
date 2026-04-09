//
//  BudgetSeedData.swift
//  Squeaky
//
//  Created by Kevin William Faith on 06/04/26.
//

import Foundation
import SwiftData

enum BudgetSeedData {
    static func seedBudgetIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<MonthlyBudget>()
        guard let existingBudgets = try? context.fetch(descriptor),
              existingBudgets.isEmpty else { return }

        
        let currentMonth = Calendar.current.component(.month, from: .now)
        let currentYear = Calendar.current.component(.year, from: .now)

        let budget = MonthlyBudget(
            month: currentMonth,
            year: currentYear,
            budgetAmount: 2000000
        )

        context.insert(budget)
        try? context.save()
    }
}

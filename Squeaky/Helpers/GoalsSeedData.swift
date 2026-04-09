//
//  GoalsSeedData.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 08/04/26.
//

import Foundation
import SwiftData


enum SavingGoalSeedData {
    static func seedSavingGoalsIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<SavingGoal>()

        // Cek apakah sudah ada data
        guard let existingGoals = try? context.fetch(descriptor),
              existingGoals.isEmpty else { return }

        let sampleGoals = [
            SavingGoal(
                title: "Buy Macbook",
                targetAmount: 15000000,
                currentAmount: 3000000,
                targetDate: Calendar.current.date(byAdding: .month, value: 6, to: .now)!
            ),
            SavingGoal(
                title: "Goes to Bali",
                targetAmount: 5000000,
                currentAmount: 1000000,
                targetDate: Calendar.current.date(byAdding: .month, value: 10, to: .now)!
            )
        ]

        // Insert ke database
        for goal in sampleGoals {
            context.insert(goal)
        }

        // Simpan perubahan
        try? context.save()
    }
}

//
//  SavingGoalService.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 09/04/26.
//

import Foundation
import SwiftUI
import SwiftData

struct SavingGoalService {
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        return formatter
    }()
    
    // MARK: - Progress
    static func progress(for goal: SavingGoal) -> CGFloat {
        let target = NSDecimalNumber(decimal: goal.targetAmount).doubleValue
        let current = NSDecimalNumber(decimal: goal.currentAmount).doubleValue
        
        guard target > 0 else { return 0 }
        return min(CGFloat(current / target), 1)
    }
    
    // MARK: - Total Saving
    static func totalSaving(goals: [SavingGoal]) -> String {
        let total = goals.reduce(0.0) {
            $0 + NSDecimalNumber(decimal: $1.currentAmount).doubleValue
        }
        
        return formatCurrency(total)
    }

    static func totalTarget(goals: [SavingGoal]) -> String {
        let total = goals.reduce(0.0) {
            $0 + NSDecimalNumber(decimal: $1.targetAmount).doubleValue
        }

        return formatCurrency(total)
    }

    static func totalProgress(goals: [SavingGoal]) -> CGFloat {
        let current = goals.reduce(0.0) {
            $0 + NSDecimalNumber(decimal: $1.currentAmount).doubleValue
        }
        let target = goals.reduce(0.0) {
            $0 + NSDecimalNumber(decimal: $1.targetAmount).doubleValue
        }

        guard target > 0 else { return 0 }
        return min(CGFloat(current / target), 1)
    }

    static func progressSummary(for goal: SavingGoal) -> String {
        "\(formatCurrency(decimal: goal.currentAmount)) / \(formatCurrency(decimal: goal.targetAmount))"
    }

    static func formatCurrency(decimal: Decimal) -> String {
        formatCurrency(NSDecimalNumber(decimal: decimal).doubleValue)
    }

    static func formatCurrency(_ value: Double) -> String {
        let number = NSNumber(value: value)
        let formattedValue = currencyFormatter.string(from: number) ?? "0"
        return "Rp \(formattedValue)"
    }

    static func addProgress(
        to goal: SavingGoal,
        amount: Double,
        context: ModelContext
    ) throws {
        goal.currentAmount += Decimal(amount)
        try context.save()
    }
}

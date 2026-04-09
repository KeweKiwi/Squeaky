//
//  ChallengeHelper.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 09/04/26.
//

import Foundation

enum ChallengeHelper {
    
    // MARK: - Reset
    
    static func shouldReset(
        lastResetDate: Date,
        resetType: ResetType
    ) -> Bool {
        
        let calendar = Calendar.current
        let now = Date()
        
        switch resetType {
        case .daily:
            return !calendar.isDateInToday(lastResetDate)
        case .weekly:
            return !calendar.isDate(lastResetDate, equalTo: now, toGranularity: .weekOfYear)
        case .monthly:
            return !calendar.isDate(lastResetDate, equalTo: now, toGranularity: .month)
        case .none:
            return false
        }
    }
    
    // MARK: - Evaluation
    
    static func evaluate(
        definition: ChallengeDefinition,
        transactions: [Transaction]
    ) -> Bool {
        
        switch definition.type {
        case .maxSpending:
            return evaluateMaxSpending(definition, transactions)
            
        case .consecutiveSavingDays:
            return evaluateStreak(definition, transactions)

        case .transactionCount:
            return evaluateTransactionCount(definition, transactions)
            
        default:
            return false
        }
    }
    
    // MARK: - Max Spending
    
    private static func evaluateMaxSpending(
        _ def: ChallengeDefinition,
        _ transactions: [Transaction]
    ) -> Bool {
        
        guard let limit = def.limitAmount,
              let category = def.category else { return false }
        
        let today = Date()
        
        let total = transactions
            .filter {
                $0.type == .expense &&
                $0.category?.name == category &&
                Calendar.current.isDate($0.date, inSameDayAs: today)
            }
            .reduce(Decimal(0)) { $0 + $1.amount }
        
        return total <= limit
    }
    
    // MARK: - Streak
    
    private static func evaluateStreak(
        _ def: ChallengeDefinition,
        _ transactions: [Transaction]
    ) -> Bool {
        
        guard let days = def.durationDays else { return false }
        
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: transactions) {
            calendar.startOfDay(for: $0.date)
        }
        
        let sortedDays = grouped.keys.sorted()
        
        var streak = 0
        var prev: Date?
        
        for day in sortedDays {
            if let p = prev,
               calendar.dateComponents([.day], from: p, to: day).day == 1 {
                streak += 1
            } else {
                streak = 1
            }
            prev = day
        }
        
        return streak >= days
    }

    private static func evaluateTransactionCount(
        _ def: ChallengeDefinition,
        _ transactions: [Transaction]
    ) -> Bool {
        guard let targetCount = def.targetCount else { return false }

        let today = Date()
        let count = transactions.filter {
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }.count

        return count >= targetCount
    }
}

//
//  ChallengeDefinition.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 09/04/26.
//

import Foundation

struct ChallengeDefinition {
    let id: UUID
    let name: String
    let type: ChallengeType
    let resetType: ResetType
    
    let category: String?
    let limitAmount: Decimal?
    let targetCount: Int?
    let durationDays: Int?
    
    let experienceReward: Int
    
    init(
        id: UUID,
        name: String,
        type: ChallengeType,
        resetType: ResetType,
        category: String? = nil,
        limitAmount: Decimal? = nil,
        targetCount: Int? = nil,
        durationDays: Int? = nil,
        experienceReward: Int
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.resetType = resetType
        self.category = category
        self.limitAmount = limitAmount
        self.targetCount = targetCount
        self.durationDays = durationDays
        self.experienceReward = experienceReward
    }
}

enum ChallengeType: String, Codable, CaseIterable {
    
    /// Limit spending within a category (e.g. Food ≤ 50k today)
    case maxSpending
    
    /// Save money for consecutive days (e.g. save for 3 days)
    case consecutiveSavingDays
    
    /// Make a certain number of transactions
    case transactionCount
    
    /// Spend total amount within a period
    case totalSpending
    
    /// Earn/save a total amount
    case totalSaving
    
    /// Log in or perform any action daily (streak-based)
    case dailyStreak
}

enum ResetType: String, Codable, CaseIterable{
    case none
    case daily
    case weekly
    case monthly
}

//
//  ChallengeDefinitionSeedData.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 09/04/26.
//
import Foundation

enum ChallengeDefinitions {
    static let all: [ChallengeDefinition] = [
        ChallengeDefinition(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Daily Food Budget",
            type: .maxSpending,
            resetType: .daily,
            category: "Food",
            limitAmount: 50000,
            targetCount: nil,
            durationDays: nil,
            experienceReward: 10
        ),
        ChallengeDefinition(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Save 3 Days",
            type: .consecutiveSavingDays,
            resetType: .none,
            category: nil,
            limitAmount: nil,
            targetCount: nil,
            durationDays: 3,
            experienceReward: 20
        ),
        ChallengeDefinition(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            name: "Log 3 Transactions",
            type: .transactionCount,
            resetType: .daily,
            category: nil,
            limitAmount: nil,
            targetCount: 3,
            durationDays: nil,
            experienceReward: 100
        ),
        ChallengeDefinition(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
            name: "Log 5 Transactions",
            type: .transactionCount,
            resetType: .daily,
            category: nil,
            limitAmount: nil,
            targetCount: 5,
            durationDays: nil,
            experienceReward: 100
        )
    ]
}

//
//  ChallengeViewModel.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 09/04/26.
//

import Foundation
import Combine
import SwiftData

class ChallengeViewModel: ObservableObject {
    
    // MARK: - Data
    @Published var challenges: [Challenge] = []
    @Published var viewData: [ChallengeViewData] = []
    
    private let definitions = ChallengeDefinitions.all
    
    // MARK: - Public Functions
    
    func load(context: ModelContext) {
        let descriptor = FetchDescriptor<Challenge>()
        guard let result = try? context.fetch(descriptor) else { return }
        
        self.challenges = result
        mapToViewData()
    }
    
    func evaluateAll(transactions: [Transaction]) {
        
        for challenge in challenges {
            
            guard let def = getDefinition(for: challenge) else { continue }
            
            // 🔁 Reset
            if ChallengeHelper.shouldReset(
                lastResetDate: challenge.lastResetDate,
                resetType: def.resetType
            ) {
                resetChallenge(challenge)
            }
            
            // ⚙️ Evaluate
            challenge.isCompleted = ChallengeHelper.evaluate(
                definition: def,
                transactions: transactions
            )
        }
        
        mapToViewData()
    }
    
    func claim(_ challenge: Challenge, pet: Pet) {
        guard challenge.isCompleted, !challenge.isClaimed else { return }
        
        guard let def = getDefinition(for: challenge) else { return }
        
        pet.currentXP += def.experienceReward
        challenge.isClaimed = true
        
        mapToViewData()
    }

    // MARK: - Private Functions

    private func getDefinition(for challenge: Challenge) -> ChallengeDefinition? {
        definitions.first { $0.id == challenge.definitionId }
    }

    private func resetChallenge(_ challenge: Challenge) {
        challenge.isCompleted = false
        challenge.isClaimed = false
        challenge.lastResetDate = Date()
    }

    private func mapToViewData() {
        viewData = challenges.compactMap { challenge in
            guard let def = getDefinition(for: challenge) else { return nil }

            return ChallengeViewData(
                id: challenge.id,
                name: def.name,
                isCompleted: challenge.isCompleted,
                isClaimed: challenge.isClaimed,
                progressText: challenge.isClaimed ? "Claimed" : (challenge.isCompleted ? "Completed" : "In Progress"),
                rewardXP: def.experienceReward
            )
        }
    }
}

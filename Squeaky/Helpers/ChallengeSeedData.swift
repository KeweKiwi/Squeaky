//
//  ChallengeSeedData.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 08/04/26.
//

import Foundation
import SwiftData

enum ChallengeSeedData {
    static func seedChallengeIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Challenge>()

        guard let existing = try? context.fetch(descriptor), existing.isEmpty
        else { return }

        let challenges = ChallengeDefinitions.all.map { definition in
            Challenge(
                definitionId: definition.id,
                isCompleted: false,
                experienceReceived: definition.experienceReward
            )
        }
        
        for challenge in challenges {
            context.insert(challenge)
        }

        try? context.save()
    }

}

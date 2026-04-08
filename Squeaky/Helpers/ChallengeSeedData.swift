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

        let challenges: [Challenge] = [
            Challenge(
                id: UUID(),
                challenge_name: "Track your spending",
                experience_received: 10,
                isCompleted: false
            ),
            Challenge(
                id: UUID(),
                challenge_name: "Stay under budget",
                experience_received: 20,
                isCompleted: false
            ),
            Challenge(
                id: UUID(),
                challenge_name: "Log 3 transactions",
                experience_received: 15,
                isCompleted: false
            ),
            Challenge(
                id: UUID(),
                challenge_name: "No impulse buying",
                experience_received: 25,
                isCompleted: false
            )
        ]
        
        for challenge in challenges {
            context.insert(challenge)
        }

        try? context.save()
    }

}

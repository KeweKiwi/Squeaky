//
//  Challenge.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 08/04/26.
//

import Foundation
import SwiftData

@Model
final class Challenge {
    var id: UUID
    
    // 🔗 Link to definition
    var definitionId: UUID
    var experienceReceived: Int
    
    // State
    var isCompleted: Bool
    var isClaimed: Bool
    
    // Reset tracking
    var lastResetDate: Date
    
    init(
        id: UUID = UUID(),
        definitionId: UUID,
        isCompleted: Bool = false,
        isClaimed: Bool = false,
        lastResetDate: Date = Date(),
        experienceReceived: Int
    ) {
        self.id = id
        self.definitionId = definitionId
        self.experienceReceived = experienceReceived
        self.isCompleted = isCompleted
        self.isClaimed = isClaimed
        self.lastResetDate = lastResetDate
    }
}

//
//  Challenge.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 08/04/26.
//

import Foundation
import SwiftData

@Model
final class Challenge: Identifiable {
    var id: UUID
    var challenge_name: String
    var experience_received: Int
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        challenge_name: String,
        experience_received: Int,
        isCompleted: Bool = false
    ){
        self.id = id
        self.challenge_name = challenge_name
        self.experience_received = experience_received
        self.isCompleted = isCompleted
    }
}

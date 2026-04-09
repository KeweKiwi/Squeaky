//
//  ChallengeViewData.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 09/04/26.
//
import Foundation

struct ChallengeViewData: Identifiable {
    let id: UUID
    let name: String
    
    let isCompleted: Bool
    let isClaimed: Bool
    
    let progressText: String
    let rewardXP: Int
}

//
//  Pet.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 08/04/26.
//

import Foundation
import SwiftData

@Model
final class Pet: Identifiable {
    var id: UUID
    var level: Int
    var currentXP: Int
    var maxXP: Int
    
    init(
        id: UUID = UUID(),
        level: Int = 1,
        currentXP: Int = 0,
        maxXP: Int = 100
    ){
        self.id = id
        self.level = level
        self.currentXP = currentXP
        self.maxXP = maxXP
    }
    
}

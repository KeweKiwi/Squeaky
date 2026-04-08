//
//  PetSeedData.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 08/04/26.
//

import Foundation
import SwiftData

enum PetSeedData {
    static func petSeedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Pet>()

        guard let existing = try? context.fetch(descriptor), existing.isEmpty
        else { return }

        let defaultPet = Pet(
            level: 1,
            currentXP: 0,
            maxXP: 100
        )

        context.insert(defaultPet)
    }
}

//
//  SavingGoal.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import Foundation
import SwiftData

@Model
final class SavingGoal {
    var id: UUID
    var title: String
    var targetAmount: Decimal
    var currentAmount: Decimal
    var targetDate: Date?
    var note: String?

    init(
        id: UUID = UUID(),
        title: String,
        targetAmount: Decimal,
        currentAmount: Decimal = 0,
        targetDate: Date? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
        self.note = note
    }
}

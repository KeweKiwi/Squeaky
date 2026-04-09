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
    var title: String   // Goal Name
    var targetAmount: Decimal   //
    var currentAmount: Decimal
    var targetDate: Date

    init(
        id: UUID = UUID(),
        title: String,
        targetAmount: Decimal,
        currentAmount: Decimal = 0,
        targetDate: Date = Date()   // Secara Default akan memberi user target goals hari ini ketika belum di set
    ) {
        self.id = id
        self.title = title
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.targetDate = targetDate
    }
}

//
//  MonthlyBudget.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import Foundation
import SwiftData

@Model
final class MonthlyBudget {
    var month: Int
    var year: Int
    var budgetAmount: Double

    init(month: Int, year: Int, budgetAmount: Double) {
        self.month = month
        self.year = year
        self.budgetAmount = budgetAmount
    }
}

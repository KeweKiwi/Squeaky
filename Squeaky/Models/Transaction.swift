//
//  Transaction.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import Foundation
import SwiftData

enum TransactionType: String, Codable, CaseIterable {
    case income
    case expense
}

@Model
final class Transaction {
    var id: UUID
    var title: String
    var amount: Decimal
    var type: TransactionType
    var date: Date
    var note: String?
    var category: Category?

    init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        type: TransactionType,
        date: Date = .now,
        note: String? = nil,
        category: Category? = nil
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.type = type
        self.date = date
        self.note = note
        self.category = category
    }
}

//
//  SeedData.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import Foundation
import SwiftData

enum SeedData {
    static func seedCategoriesIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Category>()

        guard let existing = try? context.fetch(descriptor), existing.isEmpty else { return }

        let categories: [(String, CategoryType)] = [
            ("Food", .expense),
            ("Clothing", .expense),
            ("Transport", .expense),
            ("Beauty", .expense),
            ("Entertainment", .expense),
            ("Gift", .expense),
            ("Medical", .expense),
            ("Debt", .expense),
            ("Daily", .expense),
            ("Salary", .income),
            ("Allowance", .income),
            ("Bonus", .income),
            ("Other", .expense)
        ]

        for item in categories {
            let category = Category(
                id: UUID(),
                name: item.0,
                type: item.1
            )
            context.insert(category)
        }

        try? context.save()
    }
}

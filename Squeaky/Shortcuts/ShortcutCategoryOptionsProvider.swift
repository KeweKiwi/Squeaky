//
//  ShortcutCategoryOptionsProvider.swift
//  Squeaky
//
//  Created by Kevin William Faith on 06/04/26.
//

import AppIntents

struct ShortcutCategoryOptionsProvider: DynamicOptionsProvider {
    @IntentParameterDependency<AddTransactionFromShortcutIntent>(\.$type)
    var intent

    func results() async throws -> [ShortcutCategoryOption] {
        guard let selectedType = intent?.type else {
            return ShortcutCategoryOption.allCases
        }

        switch selectedType {
        case .income:
            return [
                .salary,
                .allowance,
                .bonus,
                .freelance,
                .other
            ]

        case .expense:
            return [
                .food,
                .clothing,
                .transport,
                .beauty,
                .entertainment,
                .gift,
                .medical,
                .debt,
                .daily,
                .other
            ]
        }
    }
}

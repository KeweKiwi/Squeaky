//
//  ShortcutCategoryOptionsProvider.swift
//  Squeaky
//
//  Created by Kevin William Faith on 06/04/26.
//

import AppIntents

// ini provider buat nentuin category apa aja yang muncul di shortcut
// jadi category yang tampil bisa beda tergantung user pilih income atau expense
struct ShortcutCategoryOptionsProvider: DynamicOptionsProvider {
    
    // ini nyambung ke parameter type yang ada di AddTransactionFromShortcutIntent
    // jadi provider ini bisa "ngintip" user lagi pilih income atau expense
    @IntentParameterDependency<AddTransactionFromShortcutIntent>(\.$type)
    var intent

    // function ini yang dipanggil shortcuts buat minta daftar category
    func results() async throws -> [ShortcutCategoryOption] {
        
        // guard ini ngecek apakah type udah kebaca atau belum
        // kalau belum kebaca, balikin semua category dulu
        guard let selectedType = intent?.type else {
            return ShortcutCategoryOption.allCases
        }

        // kalau type udah ada, pilih category sesuai type
        switch selectedType {
        case .income:
            // kalau user pilih income, yang muncul cuma category income
            return [
                .salary,
                .allowance,
                .bonus,
                .freelance,
                .other
            ]

        case .expense:
            // kalau user pilih expense, yang muncul cuma category expense
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

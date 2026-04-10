//
//  AddTransactionFromShortcutIntent.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import AppIntents
import SwiftData
import Foundation

// ini intent utama buat shortcut add transaction
// jadi waktu user jalanin shortcut, logic di file ini yang dipakai
struct AddTransactionFromShortcutIntent: AppIntent {
    
    // judul intent yang tampil di shortcuts
    static var title: LocalizedStringResource = "Add Transaction"
    
    // deskripsi intent biar user tahu function shortcut ini buat apa
    static var description = IntentDescription("Save a transaction directly into Squeaky.")
    
    // kalau true, app squeaky bakal kebuka setelah shortcut dijalanin
    static var openAppWhenRun: Bool = true

    // input nama transaction dari user
    @Parameter(title: "Transaction Name")
    var titleText: String

    // input amount dari user
    @Parameter(title: "Amount")
    var amount: Double

    // input type income / expense
    @Parameter(title: "Type")
    var type: ShortcutTransactionType

    // input category
    // category ini pakai provider supaya pilihannya bisa berubah
    // misal kalau income ya muncul category income aja
    @Parameter(
        title: "Category",
        optionsProvider: ShortcutCategoryOptionsProvider()
    )
    var category: ShortcutCategoryOption

    // input tanggal transaction
    @Parameter(title: "Date")
    var date: Date

    // ini ngatur ringkasan tampilan intent di shortcuts
    // jadi user bisa lihat shortcut ini dibaca seperti kalimat biasa
    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$type) named \(\.$titleText), amount \(\.$amount), category \(\.$category), on \(\.$date)")
    }

    // function utama yang dijalankan waktu shortcut dipencet
    // @MainActor dipakai untuk menandai bahwa function / code itu harus jalan di main thread / jalur utama, supaya aman dan sesuai untuk kerja yang terkait ui atau context utama.
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        // ini ambil context dari shared swiftdata container
        // jadi shortcut dan app utama pakai database yang sama
        let context = SharedModelContainer.container.mainContext

        // ubah type shortcut ke type model app
        let transactionType: TransactionType = (type == .income) ? .income : .expense
        
        // category type juga disesuaikan dengan type transaction
        let categoryType: CategoryType = (type == .income) ? .income : .expense
        
        // ubah raw value category jadi bentuk capitalized
        // contoh: "food" -> "Food"
        let categoryName = category.rawValue.capitalized

        // ambil semua category yang udah ada di swiftdata
        let descriptor = FetchDescriptor<Category>()
        let existingCategories = try context.fetch(descriptor)

        // cari category yang namanya sama dan type-nya cocok
        // kalau ketemu, pakai yang lama
        // kalau belum ada, bikin category baru lalu insert
        let finalCategory = existingCategories.first {
            $0.name.lowercased() == categoryName.lowercased() && $0.type == categoryType
        } ?? {
            let newCategory = Category(
                id: UUID(),
                name: categoryName,
                type: categoryType
            )
            context.insert(newCategory)
            return newCategory
        }()

        // bikin object transaction baru dari input shortcut
        let transaction = Transaction(
            id: UUID(),
            title: titleText,
            amount: Decimal(amount),
            type: transactionType,
            date: date,
            note: nil,
            category: finalCategory
        )

        // masukin transaction ke swiftdata
        context.insert(transaction)
        
        // save biar beneran tersimpan di database lokal
        try context.save()

        // dialog yang muncul setelah shortcut sukses
        return .result(dialog: "Transaction saved to Squeaky.")
    }
}

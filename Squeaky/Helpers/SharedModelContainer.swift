//
//  SharedModelContainer.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import SwiftData

enum SharedModelContainer {
    static let appGroupID = "group.com.kevinfaith.squeaky"

    
    // Ini pakai .self karena model container butuh tipe data nya (blueprint) bukan isinya
    static let schema = Schema([
        Category.self,
        Transaction.self,
        MonthlyBudget.self,
        SavingGoal.self,
        UserStats.self,
        Challenge.self,
        Pet.self
    ])

    static let container: ModelContainer = {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(appGroupID)
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create shared ModelContainer: \(error)")
        }
    }()
}

//Jadi alurnya: data kok bisa kesimpan
//Shortcut isi form
//perform() dijalankan
//context.insert(transaction)
//try context.save()
//ContentView baca lagi lewat @Query


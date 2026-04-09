//
//  ContentView.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import SwiftData
import SwiftUI

enum MainTab: Hashable {
    case overview
    case add
    case transaction
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    // modelContext = pintu akses view ke database itu

    /*
     Kapan perlu modelContext

     Perlu kalau view kamu:
     - add transaction
     - delete transaction
     - edit transaction
     - seed data

     Tidak wajib kalau view kamu cuma baca pakai @Query
     */

    @State private var selectedTab: MainTab = .overview
    @State private var previousTab: MainTab = .overview
    @State private var showAddSheet = false
    // Perlu state soalnya mengubah tampilan UI (ingat kata mr ricky xD)

    var body: some View {
        TabView(selection: $selectedTab) {

            NavigationStack {  // 👈 ADD THIS
                OverviewView()
            }
            .tabItem {
                Image(systemName: "house")
                Text("Overview")
            }
            .tag(MainTab.overview)

            Color.clear
                .tabItem {
                    Image(systemName: "plus.app")
                    Text("Add")
                }
                .tag(MainTab.add)

            NavigationStack {  // 👈 ADD THIS
                TransactionListFlow()
            }
            .tabItem {
                Image(systemName: "list.bullet.rectangle")
                Text("Transaction")
            }
            .tag(MainTab.transaction)
        }
        .onChange(of: selectedTab) { _, newValue in
            if newValue == .add {
                selectedTab = previousTab
                showAddSheet = true
            } else {
                previousTab = newValue
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddTransactionView()
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
        }
        .task {
            SeedData.seedCategoriesIfNeeded(context: modelContext)
            BudgetSeedData.seedBudgetIfNeeded(context: modelContext)
            TransactionSeedData.seedTransactionsIfNeeded(context: modelContext)
            PetSeedData
                .petSeedIfNeeded(context:      modelContext)
            ChallengeSeedData.seedChallengeIfNeeded(context: modelContext)
        }
        .toolbarBackground(.white, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [
                Category.self, Transaction.self, MonthlyBudget.self,
                SavingGoal.self, UserStats.self,
                Pet.self,
                Challenge.self
            ],
            inMemory: true
        )

    // LHO kenapa kok parameternya banyak? ya soalnya ini kan menu utama dan disini ada overview add sama transaction yang membutuhkan beberapa model

    /*
     bcos ContentView di bawahnya bisa memakai beberapa model ini, misalnya:
     -  TransactionListFlow pakai Transaction
     - AddTransactionView pakai Category dan Transaction
     - overview bisa pakai MonthlyBudget
     - dll

     Gak harus semua, tapi harus mencakup model yang dipakai oleh view itu dan anaknya.
     so preview dikasih semua model yang mungkin dibutuhkan.
     */
}

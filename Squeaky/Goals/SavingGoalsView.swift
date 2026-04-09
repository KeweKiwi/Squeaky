//
//  SavingGoalsView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 06/04/26.
//

import SwiftUI
import SwiftData

struct SavingGoalsView: View {
    
    // MARK: - Environment
    @Environment(\.modelContext) private var context
    
    // MARK: - Data
    @Query(sort: \SavingGoal.targetDate) private var goals: [SavingGoal]
    
    // MARK: - State
    @State private var showEnterGoals: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer
                
                VStack(spacing: 0) {
                    headerSection
                    contentSection
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .sheet(isPresented: $showEnterGoals) {
                EnterGoalView()
            }
            .onAppear {
                BudgetSeedData.seedBudgetIfNeeded(context: context)
                SavingGoalSeedData.seedSavingGoalsIfNeeded(context: context)
            }
        }
    }
}

// MARK: - Background
private extension SavingGoalsView {
    
    var backgroundLayer: some View {
        Color.white.ignoresSafeArea()
    }
}

// MARK: - Header Section
private extension SavingGoalsView {
    
    var headerSection: some View {
        ZStack {
            headerBackground
            
            VStack {
                headerContent
                Spacer()
            }
        }
    }
    
    var headerBackground: some View {
        UnevenRoundedRectangle(
            bottomLeadingRadius: 150,
            bottomTrailingRadius: 150
        )
        .fill(Color(red: 0.95, green: 0.88, blue: 1.0))
        .frame(height: 400)
        .ignoresSafeArea()
    }
    
    var headerContent: some View {
        VStack(spacing: 16) {
            Text("Total Saving")
                .font(.headline)
                .foregroundColor(.black)
            
            Text(SavingGoalService.totalSaving(goals: goals))
                .font(.title3)
                .bold()
                .foregroundColor(.black)

            Text("\(SavingGoalService.totalSaving(goals: goals)) / \(SavingGoalService.totalTarget(goals: goals))")
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.7))

            DonutChart(progress: SavingGoalService.totalProgress(goals: goals), lineWidth: 18, size: 170)
        }
        .padding(.top, 110)
    }
}

// MARK: - Content Section
private extension SavingGoalsView {
    
    var contentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Saving Goals")
                .font(.system(size: 32, weight: .bold))
                .padding(.horizontal)
                .padding(.top, 10)
            
            ScrollView {
                VStack(spacing: 16) {
                    
                    
                    ForEach(goals) { goal in
                        GoalRow(goal: goal)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Toolbar
private extension SavingGoalsView {
    
    var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEnterGoals = true
                } label: {
                    Text("Add Goals")
                        .fontWeight(.bold)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SavingGoalsView()
}

//
//  SavingGoalsView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 06/04/26.
//

import SwiftUI
import SwiftData

struct SavingGoalsView: View {
    @Environment(\.modelContext) private var context

    @Query(sort: \SavingGoal.targetDate) private var goals: [SavingGoal]

    @State private var showEnterGoals: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Circle()
                    .fill(Color.color4)
                    .frame(width: 590, height: 790)
                    .offset(y: -200)
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    VStack(spacing: 16) {
                        Text("Total Saving")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.black)

                        Text(SavingGoalService.totalSaving(goals: goals))
                            .font(.title3)
                            .bold()
                            .foregroundColor(.black)

                        Text("\(SavingGoalService.totalSaving(goals: goals)) / \(SavingGoalService.totalTarget(goals: goals))")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.7))

                        DonutChart(
                            progress: SavingGoalService.totalProgress(goals: goals),
                            lineWidth: 18,
                            size: 170
                        )
                    }
                    .padding(.top, 60)

                }
                
                VStack(spacing: 20) {
                    Text("Saving Goals")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.horizontal, 20)
                        .padding(.top, 50)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(goals) { goal in
                                GoalRow(goal: goal)
                            }
                            .padding(.horizontal, 90)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 400)
                
                Spacer()
            }
            
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showEnterGoals = true
                    } label: {
                        Text("Add Goals")
                            .fontWeight(.bold)
                    }
                }
            }
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

#Preview {
    SavingGoalsView()
}

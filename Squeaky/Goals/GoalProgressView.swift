//
//  GoalProgressView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 07/04/26.
//

import SwiftUI

struct GoalProgressView: View {
    let goal: SavingGoal

    @State private var showingEditModal = false
    @State private var showingAddModal = false

    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Header Section
            ZStack {
                Circle()
                    .fill(Color.color4)
                    .frame(width: 590, height: 590)
                    .offset(y: -200)
                    .ignoresSafeArea()
                VStack(spacing: 10) {
                    Text("Your goal")
                        .font(.system(size: 34, weight: .bold))
                    Text(goal.title)
                        .font(.system(size: 25))
                }
                
                .padding(.bottom, 100)
                VStack {
                    Spacer()

                    
                }
            }
            .frame(height: 300)

            // MARK: - Progress Content
            VStack(spacing: 30) {
                Text(SavingGoalService.progressSummary(for: goal))
                    .font(.system(size: 18))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.top, 40)

                Chart(
                    progress: SavingGoalService.progress(for: goal),
                    height: 35
                )
                
                .frame(height: 24)
                .padding(.horizontal, 130)

                Button(action: {
                    showingAddModal = true
                }) {
                    Text("Add Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 54)
                        .background(Color.darkpurple)
                        .clipShape(Capsule())
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                }
                .padding(.top, 20)
            }
            Spacer()
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)

        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditModal = true
                }) {
                    Text("Edit")
                        .fontWeight(.medium)
                }
            }
        }

        // Optional styling
        .toolbarBackground(.visible, for: .navigationBar)

        // MARK: - Sheets
        .sheet(isPresented: $showingEditModal) {
            EditGoalView(goal: goal) {
                dismiss()
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showingAddModal) {
            AddProgressView(goal: goal)
                .presentationDetents([.large])
        }
    }
}

extension SavingGoalsView {

    fileprivate var headerBackground: some View {
        Circle()
            .fill(Color(red: 0.95, green: 0.88, blue: 1.0))
            .frame(width: 590, height: 590)
            .offset(y: -200)
            .ignoresSafeArea()

    }
}

#Preview {
    NavigationStack {
        GoalProgressView(
            goal: SavingGoal(
                title: "Buy BMW",
                targetAmount: 100_000_000
            )
        )
    }
}

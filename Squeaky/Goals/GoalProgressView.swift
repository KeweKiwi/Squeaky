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
                UnevenRoundedRectangle(bottomLeadingRadius: 150, bottomTrailingRadius: 150)
                    .fill(Color(red: 0.92, green: 0.85, blue: 0.98))
                    .frame(height: 340)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text(goal.title)
                            .font(.system(size: 34, weight: .bold))
                    }
                    .padding(.bottom, 150)
                }
            }
            .frame(height: 340)

            // MARK: - Progress Content
            VStack(spacing: 30) {
                Text(SavingGoalService.progressSummary(for: goal))
                    .font(.system(size: 18))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.top, 40)

                Chart(progress: SavingGoalService.progress(for: goal), height: 24)
                    .frame(height: 24)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    showingAddModal = true
                }) {
                    Text("Add Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 54)
                        .background(Color(red: 0.65, green: 0.52, blue: 0.78))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
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

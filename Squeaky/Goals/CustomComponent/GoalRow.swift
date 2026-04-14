//
//  GoalRowView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 08/04/26.
//

import SwiftUI

struct GoalRow: View {
    var goal: SavingGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(goal.title)
                        .font(.headline)

                    Text(SavingGoalService.progressSummary(for: goal))
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.8))
                }

                Spacer()

                NavigationLink(destination: GoalProgressView(goal: goal)) {
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }

            Chart(progress: SavingGoalService.progress(for: goal), height: 12)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lemon.opacity(0.4))
        .cornerRadius(16)
    }
}

#Preview {
    GoalRow(
        goal: SavingGoal(
            title: "Buy MacBook",
            targetAmount: 15_000_000,
            currentAmount: 3_000_000,
            targetDate: .now
        )
    )
}

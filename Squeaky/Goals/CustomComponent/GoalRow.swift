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
                        .foregroundColor(.secondary)
                }

                Spacer()

                NavigationLink(destination: GoalProgressView(goal: goal)) {
                    Image(systemName: "pencil.line")
                }
            }

            Chart(progress: SavingGoalService.progress(for: goal), height: 12)
        }
        .padding()
        .background(Color.purple.opacity(0.2))
        .cornerRadius(16)
    }
}
//#Preview {
//    GoalRow(title: "BMW", progress: 2.5)
//}

//
//  EditGoalView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 09/04/26.
//

import SwiftUI
import SwiftData

struct EditGoalView: View {
    let goal: SavingGoal
    var onDelete: (() -> Void)? = nil

    @State private var goalTitle: String
    @State private var timeSpan: Date
    @State private var nominalAmount: String
    @State private var showDeleteAlert = false

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Query private var budgets: [MonthlyBudget]

    init(goal: SavingGoal, onDelete: (() -> Void)? = nil) {
        self.goal = goal
        self.onDelete = onDelete
        _goalTitle = State(initialValue: goal.title)
        _timeSpan = State(initialValue: goal.targetDate)
        _nominalAmount = State(initialValue: NSDecimalNumber(decimal: goal.targetAmount).stringValue)
    }

    var body: some View {
        GoalFormContainerView(
            title: "Edit goal",
            goalTitle: $goalTitle,
            timeSpan: $timeSpan,
            nominalAmount: $nominalAmount
        ) {
            Button(action: saveGoal) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(red: 0.65, green: 0.52, blue: 0.78))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 20)

            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Text("Delete Goal")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
            }
            .buttonStyle(.bordered)
        }
        .alert("Delete Goal?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: deleteGoal)
        } message: {
            Text("This will permanently delete \"\(goal.title)\".")
        }
    }

    private func saveGoal() {
        guard let amount = Double(nominalAmount), amount > 0 else { return }

        goal.title = goalTitle
        goal.targetAmount = Decimal(amount)
        goal.targetDate = timeSpan

        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to save goal:", error)
        }
    }

    private func deleteGoal() {
        let refundedAmount = NSDecimalNumber(decimal: goal.currentAmount).doubleValue

        BudgetService.refundProgress(
            amount: refundedAmount,
            context: context,
            budgets: budgets
        )

        context.delete(goal)

        do {
            try context.save()
            dismiss()
            onDelete?()
        } catch {
            print("Failed to delete goal:", error)
        }
    }
}

#Preview {
    EditGoalView(
        goal: SavingGoal(
            title: "Buy BMW",
            targetAmount: 100_000_000,
            currentAmount: 25_000_000,
            targetDate: .now
        )
    )
}

//
//  AddProgressModalView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 07/04/26.
//

import SwiftUI
import SwiftData

struct AddProgressView: View {
    let goal: SavingGoal
    @State private var amount: String = ""
    @State private var showBudgetAlert = false
    
    @Environment(\.dismiss) var dismiss // To close the modal
    @Environment(\.modelContext) private var context
    
    @Query private var budgets: [MonthlyBudget]

    private var availableBudget: Double {
        BudgetService.currentBudget(from: budgets)?.budgetAmount ?? 0
    }

    var body: some View {
        ZStack {
            // Background Purple Header Area
            Color(.lemon.opacity(0.25))
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Drag Indicator
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                
                // Header with Close Button
                HStack {
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .buttonStyle(.glass(.regular))
                    .controlSize(.regular)
                    .buttonBorderShape(.circle)
                }
                .padding(.horizontal, 24)
                
                // Titles
                    VStack(spacing: 8) {
                        Text("Add Progress")
                            .font(.system(size: 32, weight: .bold))

                        Text(goal.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                    
                        VStack(spacing: 4) {
                            Text("Current Progress")
                                .font(.title3)
                            Text(SavingGoalService.progressSummary(for: goal))
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("Budget Available: \(SavingGoalService.formatCurrency(availableBudget))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                }
                .padding(.vertical, 20)
                
                // Main Content Card
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.headline)
                            .bold()
                        
                        Text("enter your amount of progress")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Text Field
                        TextField("Rp.", text: $amount)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(red: 0.9, green: 0.9, blue: 0.93))
                            .cornerRadius(25)
                    }
                    .padding(.top, 20)
                    
                    // Add Button
                    Button(action: {
                        
                        guard let amountDecimal = Double(amount),
                              amountDecimal > 0 else { return }

                        let success = BudgetService.addProgress(
                            amount: amountDecimal,
                            context: context,
                            budgets: budgets
                        )

                        guard success else {
                            showBudgetAlert = true
                            return
                        }

                        do {
                            try SavingGoalService.addProgress(
                                to: goal,
                                amount: amountDecimal,
                                context: context
                            )
                        } catch {
                            print("Failed to add goal progress:", error)
                            BudgetService.refundProgress(
                                amount: amountDecimal,
                                context: context,
                                budgets: budgets
                            )
                            return
                        }
                        
                        dismiss()
                    }) {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.darkpurple)
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.2), radius: 8, y: 4)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(30)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.96, green: 0.96, blue: 0.98)) // Off-white/Gray
                .clipShape(RoundedCorner(radius: 50, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onAppear {
            BudgetSeedData.seedBudgetIfNeeded(context: context)
        }
        .alert("Budget Not Enough", isPresented: $showBudgetAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Available budget is \(SavingGoalService.formatCurrency(availableBudget)).")
        }
    }
}

#Preview {
    AddProgressView(
        goal: SavingGoal(
            title: "Buy BMW",
            targetAmount: 100_000_000
        )
    )
}

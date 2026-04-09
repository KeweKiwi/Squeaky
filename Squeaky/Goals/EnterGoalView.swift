//
//  EnterGoalView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 07/04/26.
//

import SwiftUI
import SwiftData

struct EnterGoalView: View {
    @State private var goalTitle: String = ""
    @State private var timeSpan = Date()
    @State private var nominalAmount: String = ""

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GoalFormContainerView(
            title: "Enter your goal",
            goalTitle: $goalTitle,
            timeSpan: $timeSpan,
            nominalAmount: $nominalAmount
        ) {
            Button(action: saveGoal) {
                Text("Add")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(red: 0.65, green: 0.52, blue: 0.78))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            .padding(.top, 20)
        }
    }

    private func saveGoal() {
        guard let amount = Double(nominalAmount), amount > 0 else { return }

        let newGoal = SavingGoal(
            title: goalTitle,
            targetAmount: Decimal(amount),
            currentAmount: 0,
            targetDate: timeSpan
        )

        context.insert(newGoal)

        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to save goal:", error)
        }
    }
}

struct GoalFormContainerView<Actions: View>: View {
    let title: String
    @Binding var goalTitle: String
    @Binding var timeSpan: Date
    @Binding var nominalAmount: String
    @ViewBuilder let actions: () -> Actions

    var body: some View {
        ZStack {
            Color(red: 0.92, green: 0.85, blue: 0.98)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .padding(.top, 12)

                    HStack {
                        Spacer()
                    }
                    .padding(.trailing, 24)
                }

                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 36, weight: .bold))
                    Text("🚀")
                        .font(.system(size: 36))
                }
                .padding(.top, 20)
                .padding(.bottom, 30)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        InputView(
                            title: "Your Goal",
                            placeholder: "Your Goal",
                            text: $goalTitle,
                            keyboardType: .default
                        )

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Time Span")
                                .font(.headline)

                            DatePicker(
                                "Target Date",
                                selection: $timeSpan,
                                in: Date()...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(24)
                        }

                        InputView(
                            title: "Amount",
                            placeholder: "Rp.xx.xxx.xxx",
                            text: $nominalAmount,
                            keyboardType: .numberPad
                        )

                        actions()

                        Spacer()
                    }
                    .padding(30)
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.96, green: 0.96, blue: 0.98))
                .clipShape(RoundedCorner(radius: 50, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

struct InputView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black.opacity(0.8))

            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .padding(.horizontal, 20)
                .frame(height: 50)
                .background(Color(red: 0.9, green: 0.9, blue: 0.92))
                .cornerRadius(25)
                .keyboardType(keyboardType)
        }
    }
}

#Preview {
    EnterGoalView()
}

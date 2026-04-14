//
//  CategoryChart.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 13/04/26.
//

import SwiftUI
import Charts

struct CategoryChart: View {
    let chartData: [ExpenseCategory]
    var isExpanded: Bool = false
    var onExpand: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
    var onCategorySelected: ((ExpenseCategory) -> Void)? = nil

    @State private var selectedAngleValue: Double?

    var body: some View {
        Group {
            if isExpanded {
                expandedChart
            } else {
                compactChart
            }
        }
    }

    private var compactChart: some View {
        Button {
            onExpand?()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)

                if chartData.isEmpty {
                    ContentUnavailableView(
                        "No expense data",
                        systemImage: "chart.pie"
                    )
                    .foregroundStyle(.secondary)
                    .padding(12)
                } else {
                    chartContent(iconFont: .title2, isInteractive: false)
                        .padding(10)
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Expense category chart")
        .accessibilityHint("Opens a larger chart in the center of the screen")
    }

    private var expandedChart: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onDismiss?()
                    }

                VStack(spacing: 20) {
                    Capsule()
                        .fill(.secondary.opacity(0.35))
                        .frame(width: 44, height: 5)

                    VStack(spacing: 6) {
                        Text("Expense Breakdown")
                            .font(.title2.weight(.semibold))

                        Text("Tap a slice to open transactions in that category.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    if chartData.isEmpty {
                        ContentUnavailableView(
                            "No expense data",
                            systemImage: "chart.pie"
                        )
                        .frame(height: 260)
                    } else {
                        chartContent(iconFont: .system(size: 38), isInteractive: true)
                            .frame(height: min(geometry.size.width * 0.72, 320))

                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 120), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(chartData) { expense in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(expense.color)
                                        .frame(width: 10, height: 10)

                                    Text("\(expense.icon) \(expense.name)")
                                        .font(.footnote.weight(.medium))
                                        .lineLimit(1)

                                    Spacer(minLength: 0)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                    }

                    Button("Close") {
                        onDismiss?()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primary.opacity(0.9))
                }
                .padding(24)
                .frame(maxWidth: min(geometry.size.width - 32, 440))
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.35), lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.18), radius: 24, x: 0, y: 10)
                .padding(24)
                .transition(.scale(scale: 0.94).combined(with: .opacity))
            }
        }
        .onChange(of: selectedAngleValue) { _, newValue in
            guard
                isExpanded,
                let newValue,
                let selectedCategory = category(for: newValue)
            else {
                return
            }

            onCategorySelected?(selectedCategory)
            selectedAngleValue = nil
        }
    }

    @ViewBuilder
    private func chartContent(iconFont: Font, isInteractive: Bool) -> some View {
        let chart = Charts.Chart(chartData) { expense in
            SectorMark(
                angle: .value("Spent", expense.amount),
                innerRadius: .ratio(0.0),
                angularInset: isExpanded ? 1.5 : 0.5
            )
            .foregroundStyle(expense.color)
            .opacity(sliceOpacity(for: expense))
            .annotation(position: .overlay) {
                Text(expense.icon)
                    .font(iconFont)
                    .minimumScaleFactor(0.6)
            }
        }
        .chartLegend(.hidden)

        if isInteractive {
            chart
                .chartAngleSelection(value: $selectedAngleValue)
        } else {
            chart
        }
    }

    private func category(for angleValue: Double) -> ExpenseCategory? {
        guard !chartData.isEmpty else { return nil }

        var cumulativeAmount = 0.0
        for expense in chartData {
            cumulativeAmount += expense.amount
            if angleValue <= cumulativeAmount {
                return expense
            }
        }

        return chartData.last
    }

    private func sliceOpacity(for expense: ExpenseCategory) -> Double {
        guard
            isExpanded,
            let selectedAngleValue,
            let selectedCategory = category(for: selectedAngleValue)
        else {
            return 1
        }

        return selectedCategory.id == expense.id ? 1 : 0.45
    }
}

#Preview {
    CategoryChart(
        chartData: [
            ExpenseCategory(name: "Food", amount: 350000, color: .orange, icon: "🍔"),
            ExpenseCategory(name: "Transport", amount: 175000, color: .blue, icon: "🚕"),
            ExpenseCategory(name: "Beauty", amount: 90000, color: .pink, icon: "💄")
        ],
        isExpanded: true
    )
}

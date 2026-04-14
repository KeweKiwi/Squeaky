//
//  Chart.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 09/04/26.
//

import SwiftUI

struct Chart: View {
    var progress: CGFloat
    var height: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.1))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.lilac),
                                Color(red: 0.56, green: 0.38, blue: 0.77)
                                
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geo.size.width * progress, height))
            }
            .frame(height: height)
        }
        .frame(height: height)
    }
}

struct DonutChart: View {
    var progress: CGFloat
    var lineWidth: CGFloat = 18
    var size: CGFloat = 150

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(1), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0.02, progress))
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(.lemon),
                            Color(red: 0.56, green: 0.38, blue: 0.77)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.18, weight: .bold))
                Text("completed")
                    .font(.system(size: size * 0.08, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 24) {
        Chart(progress: 0.64)
            .frame(width: 220)
        DonutChart(progress: 0.64)
    }
}

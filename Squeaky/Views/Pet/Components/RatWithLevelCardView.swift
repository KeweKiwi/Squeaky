//
//  RatWithLevelCardView.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 07/04/26.
//

import SwiftUI

struct RatWithLevelCardView: View {
    var level: Int
    var currentXP: Int
    var maxXP: Int

    // Progress within the current level (0.0 to 1.0)
    var progress: Double {
        Double(currentXP % maxXP) / Double(maxXP)
    }

    // XP within current level
    var xpInLevel: Int {
        currentXP % maxXP
    }

    var body: some View {
        VStack(spacing: 4) {
            Image("RatLevel5")

            HStack(spacing: 0) {
                // Star badge with level number
                ZStack {
                    StarBadge(
                        corners: 9,
                        smoothness: 0.75,
                        color: Color(red: 118/255, green: 53/255, blue: 199/255),
                        cornerRadiusEffect: 1,
                        size: 50
                    )

                    Text("\(level)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .zIndex(1)
                .offset(x: 24)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(hex: "3D2DB5"), lineWidth: 1.5)
                            )

                        // Fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "DDB8F5"))
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 24)
                .padding(.leading, 8)
            }
            .padding(.trailing, 20)

            // XP label
            HStack {
                Spacer()
                Text("\(xpInLevel)/\(maxXP) XP")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundColor(.black)
            }
            .padding(.trailing, 24)
            .offset(y: -10)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack(spacing: 20) {
        RatWithLevelCardView(level: 1, currentXP: 25, maxXP: 100)
        RatWithLevelCardView(level: 5, currentXP: 520, maxXP: 100)
        RatWithLevelCardView(level: 10, currentXP: 1050, maxXP: 100)
    }
}

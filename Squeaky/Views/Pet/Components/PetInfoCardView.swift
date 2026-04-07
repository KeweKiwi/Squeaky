//
//  PetInfoCardView.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 06/04/26.
//

import SwiftUI

struct PetInfoCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rat Level")
                .font(.system(size: 14, weight: .bold))

            HStack(alignment: .bottom, spacing: 0) {
                // Rat 1
                RatStageView(imageName: "RatLevel1", level: 1)

                // Arrow
                ArrowLine()

                // Rat 5
                RatStageView(imageName: "RatLevel5", level: 5)

                // Arrow
                ArrowLine()

                // Rat 20
                RatStageView(imageName: "RatLevel20", level: 20)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color(red: 155/255, green: 155/255, blue: 155/255), lineWidth: 1)
        )
        .frame(width: 346)
    }
}

// MARK: - Rat Stage
struct RatStageView: View {
    let imageName: String
    let level: Int

    var body: some View {
        VStack(spacing: 4) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)

            // Star badge with level
            ZStack {
                Image(systemName: "seal.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color(red: 118/255, green: 53/255, blue: 199/255))

                Text("\(level)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Arrow Line
struct ArrowLine: View {
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color(hex: "3B6FD4"))
                .frame(height: 2)

            Image(systemName: "arrowtriangle.right.fill")
                .resizable()
                .frame(width: 8, height: 10)
                .foregroundColor(Color(hex: "3B6FD4"))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 42) // align arrow with rat center
    }
}

#Preview {
    PetInfoCardView()
}

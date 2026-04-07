//
//  StarBadge.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 07/04/26.
//

import SwiftUI

struct StarBadge: View {
    var corners: Int = 9
    var smoothness: Double = 0.5
    
    var color: Color = .purple
    var cornerRadiusEffect: CGFloat = 8   // controls smoothness visually
    var size: CGFloat = 60

    var body: some View {
        StarIcon(corners: corners, smoothness: smoothness)
            .fill(color)
            .overlay(
                StarIcon(corners: corners, smoothness: smoothness)
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: cornerRadiusEffect,
                            lineJoin: .round
                        )
                    )
            )
            .frame(width: size, height: size)
    }
}

//
//  GaugeArcView.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 07/04/26.
//

import SwiftUI

struct GaugeArcView: View {
    /// 0.0 = far left (Low), 1.0 = far right (High)
    var value: Double = 0.5

    let segments: [(Color, Color)] = [
        (Color(hex: "2ECC71"), Color(hex: "5DBE4A")),
        (Color(hex: "5DBE4A"), Color(hex: "A8CE3B")),
        (Color(hex: "A8CE3B"), Color(hex: "F5E642")),
        (Color(hex: "F5E642"), Color(hex: "F5B800")),
        (Color(hex: "F5B800"), Color(hex: "F08C00")),
        (Color(hex: "F08C00"), Color(hex: "E74C3C")),
    ]

    let totalSegments = 6
    let gapDegrees: Double = 0
    let lineWidth: CGFloat = 60

    // Label: (text, arcAngle, rotationDegrees, yOffset)
    let labels: [(String, Double, Double, CGFloat)] = [
        ("Low",    -180.0, -90.0, -20),
        ("Normal",  -90.0,   0.0,   0),
        ("High",      0.0, -90.0, -20),
    ]

    // Needle angle: -180° (left) to 0° (right)
    private var needleAngle: Double {
        -180.0 + value * 180.0
    }

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2 - lineWidth / 2
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.75)

            let totalArc: Double = 180.0
            let totalGap = gapDegrees * Double(totalSegments - 1)
            let segmentArc = (totalArc - totalGap) / Double(totalSegments)

            ZStack {
                // Arc segments
                ForEach(0..<totalSegments, id: \.self) { i in
                    let startAngle = -180.0 + Double(i) * (segmentArc + gapDegrees)
                    let endAngle = startAngle + segmentArc

                    SegmentArc(
                        center: center,
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        lineWidth: lineWidth,
                        startColor: segments[i].0,
                        endColor: segments[i].1
                    )
                }

                // Labels
                ForEach(labels, id: \.0) { label, angleDeg, rotation, yOffset in
                    let angle = angleDeg * .pi / 180.0
                    let labelRadius = radius + lineWidth / 2 + 16
                    let x = center.x + labelRadius * cos(angle)
                    let y = center.y + labelRadius * sin(angle)

                    Text(label)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .rotationEffect(.degrees(rotation))
                        .position(x: x, y: y + yOffset)
                }

                // Cortisol label pinned to top center of the ZStack
                VStack {
                    Text("Cortisol Level")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black).padding(.top, -100)
                }
                .frame(maxWidth: .infinity)

                // Needle
                NeedleView(
                    center: center,
                    radius: radius,
                    angleDeg: needleAngle
                )
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: value)

                // Center dot
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .shadow(radius: 2)
                    .position(center)
            }
        }
    }
}

// MARK: - Needle
struct NeedleView: View {
    let center: CGPoint
    let radius: CGFloat
    let angleDeg: Double

    var body: some View {
        Canvas { context, size in
            let angleRad = angleDeg * .pi / 180.0

            // Tip lands on the arc
            let tipX = center.x + radius * cos(angleRad)
            let tipY = center.y + radius * sin(angleRad)

            // Tail stub going opposite direction
            let tailLength: CGFloat = 20
            let tailX = center.x - tailLength * cos(angleRad)
            let tailY = center.y - tailLength * sin(angleRad)

            // Base width at pivot
            let baseOffset: CGFloat = 6
            let perpX = -sin(angleRad) * baseOffset
            let perpY =  cos(angleRad) * baseOffset

            // Tail width
            let tailOffset: CGFloat = 3
            let tailPerpX = -sin(angleRad) * tailOffset
            let tailPerpY =  cos(angleRad) * tailOffset

            var path = Path()
            path.move(to: CGPoint(x: tipX, y: tipY))
            path.addLine(to: CGPoint(x: center.x + perpX, y: center.y + perpY))
            path.addLine(to: CGPoint(x: tailX + tailPerpX, y: tailY + tailPerpY))
            path.addLine(to: CGPoint(x: tailX - tailPerpX, y: tailY - tailPerpY))
            path.addLine(to: CGPoint(x: center.x - perpX, y: center.y - perpY))
            path.closeSubpath()

            context.fill(path, with: .color(.black.opacity(0.85)))
        }
    }
}

struct SegmentArc: View {
    let center: CGPoint
    let radius: CGFloat
    let startAngle: Double
    let endAngle: Double
    let lineWidth: CGFloat
    let startColor: Color
    let endColor: Color

    var body: some View {
        let path = Path { p in
            p.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(startAngle),
                endAngle: .degrees(endAngle),
                clockwise: false
            )
        }

        path
            .stroke(
                LinearGradient(
                    colors: [startColor, endColor],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
            )
    }
}

// MARK: - Color Hex Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    GaugeArcView(value: 0)
        .frame(width: 300, height: 400)
}

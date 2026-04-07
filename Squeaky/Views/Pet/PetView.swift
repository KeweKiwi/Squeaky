import SwiftUI

struct PetView: View {
    var body: some View {
        ZStack(alignment: .top) {
            // Fixed background
            Circle()
                .fill(Color(red: 248/255, green: 206/255, blue: 23/255))
                .frame(width: 590, height: 590)
                .offset(y: -350)
                .opacity(0.3)
                .ignoresSafeArea()

            // Scrollable content
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 16) {

                    VStack(alignment: .center, spacing: 4) {
                        Text("Grow your Squeaky!")
                            .font(.system(size: 28, weight: .semibold))

                        Text("Complete Challenges to gain xp")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.black)

                        VStack(spacing: 0) {
                            GaugeArcView(value: 0.5)
                                .frame(width: 300, height: 220)

                            RatWithLevelCardView(level: 8, currentXP: 25, maxXP: 100)
                                .frame(width: 400)
                                .padding(.top, -90)
                        }
                        .frame(maxWidth: 300)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Small Challenges")
                            .font(.system(size: 16, weight: .semibold))

                        ForEach(1...4, id: \.self) { _ in
                            ChallengeCardView(isCompleted: false)
                        }
                    }
                }
                .padding(20)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    PetView()
}

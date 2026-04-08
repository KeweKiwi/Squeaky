import SwiftUI

struct PetView: View {
    @State private var isShowInfo: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {

                // Fixed background
                Circle()
                    .fill(Color(red: 248 / 255, green: 206 / 255, blue: 23 / 255))
                    .frame(width: 590, height: 590)
                    .offset(y: -200)
                    .opacity(0.3)
                    .ignoresSafeArea()

                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 16) {

                        VStack(alignment: .center, spacing: 4) {
                            Text("Grow your Squeaky!")
                                .font(.system(size: 28, weight: .semibold)

                                )

                            Text("Complete Challenges to gain xp")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.black)

                            VStack(spacing: 0) {
                                GaugeArcView(value: 0.5)
                                    .frame(width: 300, height: 220)

                                RatWithLevelCardView(
                                    level: 20,
                                    currentXP: 25,
                                    maxXP: 100
                                )
                                .frame(width: 400)
                                .padding(.top, -90)
                            }
                        }

                        VStack(alignment: .center, spacing: 8) {
                            Text("Small Challenges")
                                .font(.system(size: 16, weight: .semibold))

                            ForEach(1...4, id: \.self) { _ in
                                ChallengeCardView(isCompleted: false)
                            }
                        }

                        PetInfoCardView()

                        ZStack {
                            Circle()
                                .fill(.white)
                                .overlay(
                                    Circle().stroke(.black, lineWidth: 1)
                                )
                                .frame(width: 28, height: 28)

                            Image(systemName: "questionmark")
                                .foregroundStyle(.black)
                        }
                        .offset(x: 150, y: -750)
                        .onTapGesture {
                            isShowInfo = true
                        }

                    }
                    .padding(20)
                }
            }

            // ✅ MUST be INSIDE NavigationStack
            .navigationBarTitleDisplayMode(.inline)

            // 🌑 Modal
            .overlay {
                if isShowInfo {
                    CustomModalView {
                        VStack {
                            Text("How to play?")
                                .font(.system(size: 16, weight: .semibold))
                                .padding(.bottom, 12)
                                .padding(.top, 48)

                            Text(
                            """
                            Help Squeaky level up by completing daily mini challenges and maintain it’s cortisol level. Don’t let Squeaky get stressed out!
                            """
                            )
                            .multilineTextAlignment(.center)
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: 327)
                            .padding(.bottom, 16)

                            Image("coin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 38, height: 36)
                                .padding(.bottom, 24)
                        }
                        .frame(width: 362)

                    } onClose: {
                        isShowInfo = false
                    }
                }
            }
        }
    }
}

#Preview {
    PetView()
}

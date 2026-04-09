import SwiftUI
import SwiftData

struct PetView: View {
    @Query private var challenges: [Challenge]
    @Query private var pets: [Pet]
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var modelContext

    @State private var isShowInfo: Bool = false

    private func refreshChallengeStates() {
        for challenge in challenges {
            guard let definition = ChallengeDefinitions.all.first(where: { $0.id == challenge.definitionId }) else {
                continue
            }

            if ChallengeHelper.shouldReset(
                lastResetDate: challenge.lastResetDate,
                resetType: definition.resetType
            ) {
                challenge.isCompleted = false
                challenge.isClaimed = false
                challenge.lastResetDate = Date()
            }

            challenge.isCompleted = ChallengeHelper.evaluate(
                definition: definition,
                transactions: transactions
            )
        }

        try? modelContext.save()
    }

    private func completeChallenge(_ challenge: Challenge) {
        guard challenge.isCompleted, !challenge.isClaimed, let pet = pets.first else { return }

        challenge.isClaimed = true
        pet.currentXP += challenge.experienceReceived

        while pet.currentXP >= pet.maxXP {
            pet.currentXP -= pet.maxXP
            pet.level += 1
        }

        try? modelContext.save()
    }

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

                                RatWithLevelCardView()
                                .frame(width: 400)
                                .padding(.top, -90)
                            }
                        }

                        VStack(alignment: .center, spacing: 8) {
                            Text("Small Challenges")
                                .font(.system(size: 16, weight: .semibold))

                            ForEach(challenges) { challenge in
                                ChallengeCardView(
                                    challenge: challenge,
                                    onComplete: {
                                        completeChallenge(challenge)
                                    }
                                )
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
            .onAppear {
                refreshChallengeStates()
            }
            .onChange(of: transactions.count) { _, _ in
                refreshChallengeStates()
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
    PetView().modelContainer(for: [Challenge.self], inMemory: true)
}

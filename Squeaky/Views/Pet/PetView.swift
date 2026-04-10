import SwiftUI
import SwiftData

struct PetView: View {
    @Query private var challenges: [Challenge]
    @Query private var pets: [Pet]
    @Query private var transactions: [Transaction]
    @Environment(\.modelContext) private var modelContext

    @State private var isShowInfo: Bool = false
    @State private var levelUpMessage: String?

    private var nextChallengeResetDate: Date? {
        let dates: [Date] = challenges.compactMap { challenge in
            guard let definition = ChallengeDefinitions.all.first(where: { $0.id == challenge.definitionId }) else {
                return nil
            }

            return nextResetDate(
                from: challenge.lastResetDate,
                resetType: definition.resetType
            )
        }

        return dates.min()
    }

    private func nextResetDate(from lastResetDate: Date, resetType: ResetType) -> Date? {
        let calendar = Calendar.current

        switch resetType {
        case .daily:
            return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: lastResetDate))
        case .weekly:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: calendar.startOfDay(for: lastResetDate))
        case .monthly:
            return calendar.date(byAdding: .month, value: 1, to: calendar.startOfDay(for: lastResetDate))
        case .none:
            return nil
        }
    }

    private func resetCountdownText(from date: Date, now: Date) -> String {
        let remaining = max(0, Int(date.timeIntervalSince(now)))
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

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
                transactions: transactions,
                lastResetDate: challenge.lastResetDate
            )
        }

        try? modelContext.save()
    }

    private func completeChallenge(_ challenge: Challenge) {
        guard challenge.isCompleted, !challenge.isClaimed, let pet = pets.first else { return }

        let startingLevel = pet.level
        challenge.isClaimed = true
        pet.currentXP += challenge.experienceReceived

        while pet.currentXP >= pet.maxXP {
            pet.currentXP -= pet.maxXP
            pet.level += 1
        }

        if pet.level > startingLevel {
            levelUpMessage = "Squeaky reached level \(pet.level)!"
        }

        try? modelContext.save()
    }

    var body: some View {
        ZStack(alignment: .top) {

            Circle()
                .fill(Color(red: 248 / 255, green: 206 / 255, blue: 23 / 255))
                .frame(width: 590, height: 590)
                .offset(y: -200)
                .opacity(0.3)
                .ignoresSafeArea()

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

                            RatWithLevelCardView()
                                .frame(width: 400)
                                .padding(.top, -90)
                        }
                    }

                    VStack(spacing: 8) {
                        HStack {
                            Text("Small Challenges")
                                .font(.system(size: 16, weight: .semibold))

                            Spacer()

                            if let nextChallengeResetDate {
                                TimelineView(.periodic(from: .now, by: 1)) { context in
                                    Text("Resets in \(resetCountdownText(from: nextChallengeResetDate, now: context.date))")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                        .monospacedDigit()
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(.white.opacity(0.9))
                                        )
                                }
                            } else {
                                Text("No reset")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }.padding(.horizontal, 100)

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
                }
                .padding(20)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                isShowInfo = true
            } label: {
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
            }
            .buttonStyle(.plain)
            .padding(.top, 12)
            .padding(.trailing, 20)
        }
        .onAppear {
            refreshChallengeStates()
        }
        .onChange(of: transactions.count) { _, _ in
            refreshChallengeStates()
        }
        .navigationBarTitleDisplayMode(.inline)
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

                        Upon every challenge completion, you will receive a certain amount of xp (as shown underneath each challenge), which will contribute to the increase of Squeaky’s level.

                        Squeaky’s cortisol level depends on how you manage your monthly budget. As long as your spending stays within the budget limit, Squeaky’s cortisol level will remain low to normal. However, when your spending gets closer or exceeds the limit, the cortisol indicator will move toward a higher cortisol level, making Squeaky stressed and anxious.


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
        .alert("Level Up 🎉", isPresented: levelUpAlertBinding) {
            Button("OK", role: .cancel) {
                levelUpMessage = nil
            }
        } message: {
            Text(levelUpMessage ?? "")
        }
        .toolbar(.hidden, for: .tabBar)
    }

    private var levelUpAlertBinding: Binding<Bool> {
        Binding(
            get: { levelUpMessage != nil },
            set: { isPresented in
                if !isPresented {
                    levelUpMessage = nil
                }
            }
        )
    }
}

private struct PetViewPreviewContainer: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        PetView()
            .task {
                SeedData.seedCategoriesIfNeeded(context: modelContext)
                TransactionSeedData.seedTransactionsIfNeeded(context: modelContext)
                PetSeedData.petSeedIfNeeded(context: modelContext)
                ChallengeSeedData.seedChallengeIfNeeded(context: modelContext)
            }
    }
}

#Preview {
    PetViewPreviewContainer()
        .modelContainer(
            for: [
                Challenge.self,
                Pet.self,
                Transaction.self,
                Category.self
            ],
            inMemory: true
        )
}

import SwiftUI

struct PetView: View {
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(Color(red: 248/255, green: 206/255, blue: 23/255))
                .opacity(0.3)
                .frame(width: 590, height: 590)
                .offset(y: -350)
                .zIndex(0)

            // Content
            VStack(alignment: .center, spacing: 16) {
                
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 36, height: 36)

                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }

                    Spacer()
                }

                // Title
                VStack(alignment: .center, spacing: -2) {
                    Text("Grow your Squeaky!")
                        .font(.system(size: 28, weight: .semibold))

                    Text("Complete Challenges to gain xp")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.black)
                }

                // Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Small Challenges")
                        .font(.system(size: 16, weight: .semibold))

                    ForEach(1...2, id: \.self) { _ in
                        ChallengeCardView(isCompleted: false)
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(20)
            .zIndex(1)
        }
    }
}

#Preview {
    PetView()
}

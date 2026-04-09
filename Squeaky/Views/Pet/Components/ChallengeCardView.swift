//
//  ChallengeCardView.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 06/04/26.
//

import SwiftUI

struct ChallengeCardView: View {
    let challenge: Challenge
    let onComplete: () -> Void
    
    let completedColor = Color(
        red: 63/255,
        green: 92/255,
        blue: 199/255
    )

    private var challengeDefinition: ChallengeDefinition? {
        ChallengeDefinitions.all.first { $0.id == challenge.definitionId }
    }

    private var challengeName: String {
        challengeDefinition?.name ?? "Challenge"
    }

    private var experienceReward: Int {
        challengeDefinition?.experienceReward ?? 0
    }

    private var buttonTitle: String {
        if challenge.isClaimed {
            return "Claimed"
        }

        if !challenge.isCompleted {
            return "Not Finished"
        }

        return "Claim"
    }

    private var isButtonEnabled: Bool {
        challenge.isCompleted && !challenge.isClaimed
    }
    
    var body: some View {
        HStack(){
            ZStack {
                StarBadge(
                    corners: 9,
                    smoothness: 0.75,
                    color: challenge.isCompleted
                    ? completedColor
                    : Color(red:180/255, green: 191/255, blue: 230/255),
                    cornerRadiusEffect: 1,
                    size: 36
                )
                
                Image(systemName: "checkmark")
                    .foregroundStyle(challenge.isCompleted ? .white : .gray)
                    .font(.system(size: 12, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 2){
                Text(challengeName)
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                
                Text("\(Text("+\(experienceReward) ").foregroundStyle(.primary))\(Text("experience point").foregroundStyle(Color(red: 117/255, green: 117/255, blue: 117/255)))")
                    .font(.system(size: 8))
                    .fontWeight(.light)
            }
            
            Spacer()
            
            Button {
                onComplete()
            } label: {
                Text(buttonTitle)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(challenge.isClaimed ? .white : .black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(
                                challenge.isClaimed
                                ? completedColor
                                : isButtonEnabled
                                ? Color(red: 248/255, green: 206/255, blue: 23/255)
                                : Color(red: 231/255, green: 231/255, blue: 231/255)
                            )
                    )
            }
            .buttonStyle(.plain)
            .disabled(!isButtonEnabled)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .border(Color(red: 155/255, green: 155/255, blue: 155/255), width: 1)
        .frame(width: 346)
        .background(Color(.white))
        .contentShape(Rectangle())
    }
}

#Preview {
    ChallengeCardView(
        challenge: Challenge(
            definitionId: ChallengeDefinitions.all[0].id,
            isCompleted: false,
            experienceReceived: ChallengeDefinitions.all[0].experienceReward
        ),
        onComplete: {}
    )
}

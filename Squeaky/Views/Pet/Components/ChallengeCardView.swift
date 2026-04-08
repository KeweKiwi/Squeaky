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
                Text(challenge.challenge_name)
                    .font(.system(size: 12))
                    .fontWeight(.medium)
                
                Text("\(Text("+\(challenge.experience_received) ").foregroundStyle(.primary))\(Text("experience point").foregroundStyle(Color(red: 117/255, green: 117/255, blue: 117/255)))")
                    .font(.system(size: 8))
                    .fontWeight(.light)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .border(Color(red: 155/255, green: 155/255, blue: 155/255), width: 1)
        .frame(width: 346)
        .background(Color(.white))
        .contentShape(Rectangle())
        .onTapGesture {
            guard !challenge.isCompleted else { return }
            onComplete()
        }
    }
}

#Preview {
    ChallengeCardView(
        challenge: Challenge(
            challenge_name: "Track your spending",
            experience_received: 10,
            isCompleted: false
        ),
        onComplete: {}
    )
}

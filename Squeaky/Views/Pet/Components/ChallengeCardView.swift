//
//  ChallengeCardView.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 06/04/26.
//

import SwiftUI

struct ChallengeCardView: View {
    var body: some View {
        HStack(){
            ZStack{
                
            }
            VStack(alignment: .leading, spacing: 2){
                Text("No spend day in clothing").font(.system(size: 12)).fontWeight(.medium)
                Text("\(Text("+30 ").foregroundStyle(.primary))\(Text("experience point").foregroundStyle(Color(red: 117/255, green: 117/255, blue: 117/255)))")
                    .font(.system(size: 8))
                .fontWeight(.light)
            }
            
            Spacer()
        }.padding(.horizontal, 20)
            .padding(.vertical, 8)
            .border(Color(red: 155/255, green: 155/255, blue: 155/255), width: 1).frame(width: 346)
    }
}

#Preview {
    ChallengeCardView()
}

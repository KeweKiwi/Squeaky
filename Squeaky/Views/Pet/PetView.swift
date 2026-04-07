//
//  PetView.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 06/04/26.
//

import SwiftUI

struct PetView: View {
    var body: some View {
        VStack(){
            HStack(){
                
            }
            HStack(){
                VStack(spacing: -2){
                    Text("Grow your Squeaky!").font(.system(size: 28)).fontWeight(.semibold)
                    Text("Complete Challenges to gain xp").font(.system(size: 12)).fontWeight(.medium)
                }
            }
            
            
            HStack(){
                VStack(){
                    Text("Small Challenges").font(.system(size: 16)).fontWeight(.semibold)
                    ForEach(1...2, id: \.self) { i in
                        ChallengeCardView()
                    }
                }
                
            }
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(20)
    }
}

#Preview {
    PetView()
}

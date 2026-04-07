//
//  PetInfoCardView.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 06/04/26.
//

import SwiftUI

struct PetInfoCardView: View {
    var body: some View {
        HStack(){
            VStack(alignment: .leading){
                Text("Rat Level")
                    .font(.system(size: 12)).fontWeight(.semibold)
            }
            
        }.padding(.horizontal, 20)
            .padding(.vertical, 8)
            .border(Color(red: 155/255, green: 155/255, blue: 155/255), width: 1).frame(width: 346)
    }
}

#Preview {
    PetInfoCardView()
}

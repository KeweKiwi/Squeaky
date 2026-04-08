//
//  MonthlyRecapView.swift
//  Squeaky
//
//  Created by Nayla Abel Sabathyani on 07/04/26.
//

import SwiftUI

struct MonthlyRecapView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex = 0
    let recapImages = ["Recap 1","Recap 2","Recap 3"]
    
    var body: some View {
        ZStack{
        Image(recapImages[currentIndex])
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack{
                HStack{
                    Spacer()
                    Button(action:{
                        dismiss()
                    }){
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .accentColor(.white)
                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
            
                    }
                }
                Spacer()
            }
            .padding(25)
        }
    }
}
#Preview {
    MonthlyRecapView()
}

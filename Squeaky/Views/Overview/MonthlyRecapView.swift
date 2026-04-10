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
                        Text("Done ")
                            .buttonStyle(.bordered)
                            .padding(11)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(30)
                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                    }
                }
                .padding(.top, 25)
                .padding(25)
                HStack{
                    Rectangle()
                        .fill(Color.white.opacity(0.001))
                        .ignoresSafeArea()
                        .onTapGesture {
                            if currentIndex > 0 {
                                currentIndex -= 1
                            }
                        }
                    Rectangle()
                        .fill(Color.white.opacity(0.001))
                        .ignoresSafeArea()
                        .onTapGesture {
                            if currentIndex < recapImages.count - 1 {
                                currentIndex += 1
                            } else {
                                dismiss()
                            }
                        }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
        }
    #Preview {
        MonthlyRecapView()
    }

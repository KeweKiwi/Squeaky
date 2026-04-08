//
//  CustomModalView.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 08/04/26.
//
import SwiftUI

struct CustomModalView<Content: View>: View {
    var content: Content
    var onClose: () -> Void

    init(@ViewBuilder content: () -> Content, onClose: @escaping () -> Void) {
        self.content = content()
        self.onClose = onClose
    }

    var body: some View {
        ZStack {
            // 🔥 Background overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            ZStack(alignment: .topTrailing) {

                // White modal card
                VStack {
                    content
                }
                .padding(20)
                .frame(maxWidth: 362)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 10)

                Button(action: {
                    onClose()
                }) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .overlay(Circle().stroke(.black, lineWidth: 1))
                            .frame(width: 28, height: 28)

                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 10)
                }
            }
        }
    }
}


#Preview {
    CustomModalView {
        ZStack{
            VStack() {
                Text("How to play?")
                                            .font(.system(size: 16, weight: .semibold)).padding(.bottom, 12)
                                            .padding(.top, 48)

                                        Text("""
                Help Squeaky level up by completing daily mini challenges and maintain it’s cortisol level. Don’t let Squeaky get stressed out!

                Upon every challenge completion, you will receive a certain amount of xp (as shown underneath each challenge), which will contribute to the increase of Squeaky’s level.

                Squeaky’s cortisol level depends on how you manage your monthly budget. As long as your spending stays within the budget limit, Squeaky’s cortisol level will remain low to normal. However, when your spending gets closer or exceeds the limit, the cortisol indicator will move toward a higher cortisol level, making Squeaky stressed and anxious.
                """)
                                        .multilineTextAlignment(.center).font(.system(size: 12, weight: .medium))
                                        .frame(width: 327)
                                        .padding(.bottom, 16)
                
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 36)
                    .padding(.bottom, 24)
            }.frame(width: 362)
            
        }
        
    } onClose: {
        var isClosed : Bool = false
    }

}

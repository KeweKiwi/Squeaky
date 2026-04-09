//
//  GoalRowView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 08/04/26.
//

import SwiftUI

struct GoalRow: View {
    var title: String
    var progress: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                NavigationLink(destination: GoalProgressView()) {
                    Image(systemName: "pencil.line")
                        .font(.system(size: 14, weight: .bold))
                }
                .buttonStyle(.glass(.regular))
                .buttonBorderShape(.circle)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.purple.opacity(0.3))
                        .frame(height: 12)
                    
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geo.size.width * progress, height: 12)
                        .animation(.easeInOut, value: progress) 
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(Color(red: 0.95, green: 0.88, blue: 1.0))
        .cornerRadius(16)
    }
}
//#Preview {
//    GoalRow(title: "BMW", progress: 2.5)
//}

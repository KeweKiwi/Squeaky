//
//  RatCardView.swift
//  Squeaky
//
//  Created by Christianto Elvern Haryanto on 07/04/26.
//

import SwiftUI

struct CortisolCardView: View {
    var body: some View {
        VStack(alignment: .center){
            HStack(){
                VStack(spacing: -2){
                    Text("Cortisol Level").font(.system(size: 12))
                        .fontWeight(.semibold)
                    
                    Text("Normal").font(.system(size: 16))
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    CortisolCardView()
}

//
//  AddProgressModalView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 07/04/26.
//

import SwiftUI

struct AddProgressView: View {
    @State private var amount: String = ""
    @Environment(\.dismiss) var dismiss // To close the modal

    var body: some View {
        ZStack {
            // Background Purple Header Area
            Color(red: 0.92, green: 0.85, blue: 0.98)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Drag Indicator
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                
                // Header with Close Button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    }
                }
                .padding(.horizontal, 24)
                
                // Titles
                VStack(spacing: 8) {
                    Text("Add Progress")
                        .font(.system(size: 32, weight: .bold))
                    
                    VStack(spacing: 4) {
                        Text("Your Balance")
                            .font(.title3)
                        Text("Rp xx.xxx.xxx")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, 20)
                
                // Main Content Card
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.headline)
                            .bold()
                        
                        Text("enter your amount of progress")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Text Field
                        TextField("Rp.", text: $amount)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(red: 0.9, green: 0.9, blue: 0.93))
                            .cornerRadius(25)
                    }
                    .padding(.top, 40)
                    
                    // Add Button
                    Button(action: {
                        // Add logic here
                        dismiss()
                    }) {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.65, green: 0.52, blue: 0.78))
                            .clipShape(Capsule())
                            .shadow(color: Color.black.opacity(0.2), radius: 8, y: 4)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(30)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.96, green: 0.96, blue: 0.98)) // Off-white/Gray
                .clipShape(RoundedCorner(radius: 50, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

#Preview {
    AddProgressView()
}

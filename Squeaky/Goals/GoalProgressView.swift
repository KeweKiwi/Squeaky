//
//  GoalProgressView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 07/04/26.
//

import SwiftUI

struct GoalProgressView: View {
    
    @State private var showingEditModal = false
    @State private var showingAddModal = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - Header Section
            ZStack {
                UnevenRoundedRectangle(bottomLeadingRadius: 150, bottomTrailingRadius: 150)
                    .fill(Color(red: 0.92, green: 0.85, blue: 0.98))
                    .frame(height: 340)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("Goal #1")
                            .font(.system(size: 38, weight: .bold))
                        Text("Buy BMW")
                            .font(.system(size: 28, weight: .medium))
                    }
                    .padding(.bottom, 150)
                }
            }
            .frame(height: 340)

            // MARK: - Progress Content
            VStack(spacing: 30) {
                Text("Rp xxx.xxx.xxx / Rp xxx.xxx.xxx")
                    .font(.system(size: 18))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.top, 40)
                
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 34)
                    
                    Capsule()
                        .fill(Color(red: 0.65, green: 0.52, blue: 0.78))
                        .frame(width: 250, height: 34)
                }
                .padding(.horizontal, 40)
                
                Button(action: {
                    showingAddModal = true
                }) {
                    Text("Add Progress")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 220, height: 54)
                        .background(Color(red: 0.65, green: 0.52, blue: 0.78))
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                }
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingEditModal = true
                }) {
                    Text("Edit")
                        .fontWeight(.medium)
                }
            }
        }
        
        // Optional styling
        .toolbarBackground(.visible, for: .navigationBar)
        
        // MARK: - Sheets
        .sheet(isPresented: $showingEditModal) {
            EnterGoalView()
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showingAddModal) {
            AddProgressView()
                .presentationDetents([.large])
        }
    }
}

#Preview {
    NavigationStack {
        GoalProgressView()
    }
}

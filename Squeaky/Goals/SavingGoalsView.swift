//
//  SavingGoalsView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 06/04/26.
//


import SwiftUI

struct SavingGoalsView: View {
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Saving Goals")
                            .font(.system(size: 32, weight: .bold))
                            .padding(.horizontal)
                            .padding(.top, 30)
                        
                        ScrollView {
                            VStack(spacing: 16) {
                                GoalRowView(title: "Buy BMW", progress: 0.5)
                                GoalRowView(title: "Buy BMW", progress: 0.3)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            
            // toolbar
            .toolbar {
                
                // LEFT (Back)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // isi kalau ada navigation sebelumnya
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
                
                // RIGHT (Add Goals → PUSH)
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: GoalProgressView()) {
                        Text("Add Goals")
                            .fontWeight(.bold)
                    }
                }
            }
            
            // Optional styling
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.white, for: .navigationBar)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        ZStack {
            UnevenRoundedRectangle(bottomLeadingRadius: 150, bottomTrailingRadius: 150)
                .fill(Color(red: 0.95, green: 0.88, blue: 1.0))
                .frame(height: 400)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Ring Chart / Info
                ZStack {
                    VStack {
                        Text("Total Saving")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text("Rp 101.000.000")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.black)
                    }
                }
                .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}

// MARK: - Goal Row
struct GoalRowView: View {
    var title: String
    var progress: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Image(systemName: "pencil.line")
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.purple.opacity(0.3))
                        .frame(height: 12)
                    
                    Capsule()
                        .fill(Color.white)
                        .frame(width: geo.size.width * progress, height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(Color(red: 0.95, green: 0.88, blue: 1.0))
        .cornerRadius(16)
    }
}

// MARK: - Preview
#Preview {
    SavingGoalsView()
}

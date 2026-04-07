//
//  EnterGoalView.swift
//  Squeaky
//
//  Created by ahmadfarhanqf on 07/04/26.
//

import SwiftUI

struct EnterGoalView: View {
    // MARK: - State Variables
    @State private var goalTitle: String = ""
    @State private var timeSpan = Date()
    @State private var showDatePicker: Bool = false
    @State private var nominalAmount: String = ""
    @State private var isPriority: Bool = true
    
    @Environment(\.dismiss) var dismiss // To handle closing the modal

    // MARK: - Body
    var body: some View {
        ZStack {
            // Background Purple Header Area
            Color(red: 0.92, green: 0.85, blue: 0.98) // Soft Purple
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Top Handle & Close Button
                VStack(spacing: 4) {
                    // Drag Indicator
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .padding(.top, 12)
                    
                    // Close Button Area
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 24)
                    }
                }
                
                // MARK: - Header Title
                HStack(spacing: 8) {
                    Text("Enter your goal")
                        .font(.system(size: 36, weight: .bold))
                    Text("🚀")
                        .font(.system(size: 36))
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // MARK: - Main Content Input Card
                ScrollView { // ScrollView allows usage on smaller screens
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Input Field Component (Goal Title)
                        InputView(title: "Your Goal", placeholder: "Your Goal", text: $goalTitle, keyboardType: .default)
                        
                        // Input Field Component (Time Span)
                        // This is currently a text input; in a real app, a DatePicker would be better.
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time Span")
                                .font(.headline)
                            
                            
                            Button(action: {
                                withAnimation {
                                    showDatePicker.toggle()
                                }
                            }) {
                                HStack {
                                    Text(formatDate(timeSpan))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .rotationEffect(.degrees(showDatePicker ? 180 : 0))
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            
                            if showDatePicker {
                                DatePicker(
                                    "",
                                    selection: $timeSpan,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                            }
                        }
                        
                        // Input Field Component (Nominal)
                        InputView(title: "Nominal", placeholder: "Rp.xx.xxx.xxx", text: $nominalAmount, keyboardType: .numberPad)
                        
                        // MARK: - Priority Checkbox
                        ToggleView(isOn: $isPriority, text: "Is it your priority?")
                        
                        // MARK: - Add Button
                        Button(action: {
                            // Logic to add the new goal goes here
                            dismiss()
                        }) {
                            Text("Add")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color(red: 0.65, green: 0.52, blue: 0.78)) // Muted Purple
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    .padding(30)
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.96, green: 0.96, blue: 0.98)) // Content Card Background
                .clipShape(RoundedCorner(radius: 50, corners: [.topLeft, .topRight]))
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

// MARK: - Component 1: Custom Input View
struct InputView: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black.opacity(0.8))
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .padding(.horizontal, 20)
                .frame(height: 50)
                .background(Color(red: 0.9, green: 0.9, blue: 0.92)) // Light Gray
                .cornerRadius(25)
                .keyboardType(keyboardType)
        }
    }
}

// MARK: - Component 2: Custom Toggle View
struct ToggleView: View {
    @Binding var isOn: Bool
    let text: String
    
    var body: some View {
        HStack {
            Button(action: { isOn.toggle() }) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isOn ? Color.clear : Color.gray.opacity(0.5), lineWidth: 1)
                            .frame(width: 24, height: 24)
                        
                        if isOn {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 0.05, green: 0.5, blue: 0.5)) // Custom Teal Green
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .background(isOn ? Color.clear : Color.white)
                    .cornerRadius(6)
                    
                    Text(text)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .buttonStyle(PlainButtonStyle()) // Prevent standard button fade
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(red: 0.88, green: 0.92, blue: 0.93)) // Custom Teal Background
        .cornerRadius(8)
    }
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter.string(from: date)
}


// MARK: - Preview
#Preview {
    EnterGoalView()
}

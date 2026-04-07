//
//  TransactionList.swift
//  Squeaky
//
//  Created by Gabriel Michelle Wibisono on 06/04/26.
//

import SwiftUI

// MARK: - 1. Models
struct TransactionItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let amount: Int
    let icon: String
    let iconColor: Color
}

struct DailyExpense: Identifiable {
    let id = UUID()
    let date: String
    var items: [TransactionItem]
    var isExpanded: Bool = true
    
    var total: Int {
        items.reduce(0) { $0 + $1.amount }
    }
}

// MARK: - 2. Colors & Helpers
extension Color {
    static let themeYellow = Color(red: 1.0, green: 0.98, blue: 0.88)
    static let themePurple = Color(red: 0.92, green: 0.85, blue: 0.98)
    static let themeGray = Color(red: 0.95, green: 0.95, blue: 0.95)
}

extension Int {
    var formatIDR: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "Rp"
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "Rp0"
    }
}

// MARK: - 3. Main Feature View
struct TransactionListFlow: View {
    // UI State
    @State private var isSelectionMode = false // Controls Screen 1 vs Screen 2/3
    @State private var selectedItems = Set<UUID>() // Tracks Screen 3 selections
    @State private var showDeleteAlert = false // Controls Screen 4
    @State private var selectedSegment = "Expense"
    
    // Data (Screen 5 will modify this)
    @State private var dailyExpenses = [
        DailyExpense(date: "Wednesday, 1", items: [
            TransactionItem(name: "Teh Gopek", amount: 5000, icon: "🧃", iconColor: .green),
            TransactionItem(name: "Mie ayam", amount: 25000, icon: "🍔", iconColor: .orange),
            TransactionItem(name: "Nasi goreng", amount: 10000, icon: "🍔", iconColor: .orange)
        ]),
        DailyExpense(date: "Friday, 3", items: [
            TransactionItem(name: "Teh Gopek", amount: 5000, icon: "🧃", iconColor: .green),
            TransactionItem(name: "Mie ayam", amount: 25000, icon: "🍔", iconColor: .orange),
            TransactionItem(name: "Uniqlow", amount: 80000, icon: "👚", iconColor: .purple)
        ])
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach($dailyExpenses) { $group in
                            dailyGroupView(group: $group)
                        }
                    }
                    .padding(.top, 20)
                }
                .background(Color.white)
                
                customTabBar
            }
            
            // Screen 2/3: Trash Icon (Floating)
            if isSelectionMode {
                trashIconButton
            }
            
            // Screen 4: Custom Delete Alert
            if showDeleteAlert {
                deleteAlertOverlay
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(spacing: 15) {
            // Screen 1: Top Bar
            HStack {
                Spacer()
                Button(isSelectionMode ? "Cancel" : "Select") {
                    withAnimation {
                        isSelectionMode.toggle()
                        selectedItems.removeAll()
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.8))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Month Picker
            HStack(spacing: 20) {
                Image(systemName: "chevron.left")
                Text("April 2026")
                    .font(.title3)
                    .fontWeight(.bold)
                Image(systemName: "chevron.right")
            }
            
            // Segmented Control
            HStack(spacing: 0) {
                ForEach(["Expense", "Income"], id: \.self) { tab in
                    Text(tab)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedSegment == tab ? Color.black : Color.clear)
                        .foregroundColor(selectedSegment == tab ? .white : .gray)
                        .cornerRadius(8)
                        .onTapGesture { selectedSegment = tab }
                }
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal, 40)
        }
        .padding(.top, 50)
        .padding(.bottom, 25)
        .background(Color.themeYellow)
        .clipShape(RoundedCorner(radius: 40, corners: [.bottomLeft, .bottomRight]))
    }

    private func dailyGroupView(group: Binding<DailyExpense>) -> some View {
        VStack(spacing: 0) {
            // Day Header
            HStack {
                Text(group.wrappedValue.date)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: group.wrappedValue.isExpanded ? "chevron.up" : "chevron.down")
            }
            .padding()
            .background(Color.themePurple)
            .onTapGesture { group.wrappedValue.isExpanded.toggle() }
            
            if group.wrappedValue.isExpanded {
                VStack(spacing: 0) {
                    ForEach(group.wrappedValue.items) { item in
                        HStack {
                            // Screen 2/3 Checkbox
                            if isSelectionMode {
                                Image(systemName: selectedItems.contains(item.id) ? "checkmark.square.fill" : "square")
                                    .foregroundColor(selectedItems.contains(item.id) ? .black : .gray)
                                    .onTapGesture {
                                        if selectedItems.contains(item.id) {
                                            selectedItems.remove(item.id)
                                        } else {
                                            selectedItems.insert(item.id)
                                        }
                                    }
                            }
                            
                            // Item Content
                            ZStack {
                                Circle().fill(item.iconColor.opacity(0.2)).frame(width: 35, height: 35)
                                Text(item.icon)
                            }
                            
                            Text(item.name)
                                .font(.body)
                            
                            Spacer()
                            
                            Text(item.amount.formatIDR)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        
                        Divider().padding(.leading, isSelectionMode ? 50 : 20)
                    }
                    
                    // Group Total
                    HStack {
                        Spacer()
                        Text("Total")
                            .foregroundColor(.gray)
                        Text(group.wrappedValue.total.formatIDR)
                            .fontWeight(.bold)
                    }
                    .padding()
                }
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }

    private var trashIconButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 30)
                .padding(.bottom, 100)
            }
        }
    }

    private var deleteAlertOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Are you sure you want to delete?")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 15) {
                    Button("No") {
                        showDeleteAlert = false
                        isSelectionMode = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    .foregroundColor(.black)
                    
                    Button("Yes") {
                        deleteAction() // Navigates to Screen 5
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                    .foregroundColor(.white)
                }
            }
            .padding(25)
            .background(Color.themeYellow)
            .cornerRadius(25)
            .padding(.horizontal, 40)
        }
    }

    private var customTabBar: some View {
        HStack {
            VStack { Image(systemName: "house"); Text("Overview").font(.caption2) }.frame(maxWidth: .infinity)
            VStack { Image(systemName: "plus.app"); Text("Add").font(.caption2) }.frame(maxWidth: .infinity)
            VStack {
                HStack {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Transaction").font(.caption2).fontWeight(.bold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(20)
            }.frame(maxWidth: .infinity)
        }
        .padding(.top, 10)
        .padding(.bottom, 30)
        .background(Color.themeGray)
    }

    // MARK: - 4. Logic (Screen 5 Transition)
    private func deleteAction() {
        // Filter the data: remove items that were selected
        for i in 0..<dailyExpenses.count {
            dailyExpenses[i].items.removeAll { selectedItems.contains($0.id) }
        }
        
        // Reset UI
        showDeleteAlert = false
        isSelectionMode = false
        selectedItems.removeAll()
    }
}

// MARK: - Shape Helper
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    TransactionListFlow()
}

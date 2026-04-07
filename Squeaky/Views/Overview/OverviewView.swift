//
//  OverviewView.swift
//  Squeaky
//
//  Created by Nayla Abel Sabathyani on 06/04/26.
//

import SwiftUI
import Charts

struct OverviewView: View {
    
    //DUMMY BUDGET
    let currentSpent: Int = 2000000
        let totalBudget: Int = 2000000
    
    var spentRatio: Double { Double(currentSpent) / Double(totalBudget) }
        
        let petLevel: Int = 1
    var body: some View {
    
    //DUMMY GOALS
    let dummyGoals: [OverviewSavingGoal] = [
    OverviewSavingGoal(title: "New schoolbag 💼", currentSaved: 500000, targetAmount: 2100000, isPriority: false),
    OverviewSavingGoal(title: "Japan 2027 🇯🇵!", currentSaved: 15000000, targetAmount: 30000000, isPriority: true)]
   
        
    // Main VStack: WHATS & OVERVIEW
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("What’s your money up to?")
                        .font(.system(size: 32))
                        .bold()
                    Spacer()
                    NavigationLink(destination: Text("Monthly Recap Page")){
                        Image("Fitur")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 50)
                    }
                }
                
                Text("Overview")
                    .font(.title2)
                    .bold()
            }
            
            HStack(spacing: 5) {
                
                // BALANCE CARD
                VStack(spacing: 5) {
                    HStack {
                        Image(systemName: "wallet.bifold.fill")
                            .foregroundColor(.black)
                        Text("Balance")
                            .font(.caption)
                            .bold()
                            .foregroundColor(.black)
                    }
                    .padding(0)
                    .background(Color.yellow)
                    .cornerRadius(12)
                    
                    Text("Rp. 2.000.000")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.black)
                    
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading) // Makes the box stretch out nicely
                .background(Color.yellow)
                .cornerRadius(12)
                
                // INCOME CARD
                
                    VStack(spacing: 5) {
                        HStack {
                            NavigationLink(destination: Text("Income List Page")) {
                                Image(systemName: "arrowshape.up.circle.fill")
                                    .foregroundColor(.black)
                                
                                Text("Income")
                                    .font(.caption)
                                    .bold()
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(0)
                        .background(Color.yellow)
                        .cornerRadius(12)
                        
                        Text("Rp. 5.000.000")
                            .font(.subheadline)
                            .bold()
                        
                            .foregroundColor(.black)
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading) //
                .background(Color.yellow)
                .cornerRadius(12)
                
                // EXPENSE CARD
                VStack(spacing: 5) {
                    HStack {
                        NavigationLink(destination: Text("Expense List Page")) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.black)
                            Text("Expense")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.black)
                        }
                    }
                        
                    .padding(0)
                    .background(Color.yellow)
                    .cornerRadius(12)
                    
                    Text("Rp. 3.000.000")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.black)
                    
                }
                .padding(15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.yellow)
                .cornerRadius(12)
                
            }//TUTUP HSTACK 3 NOMINAL
            
            //BUDGET THIS MONTH
            VStack(alignment: .leading, spacing: 15){
                HStack{
                    Text("Budget this Month")
                        .font(.body)
                        .bold()
                    NavigationLink(destination: Text("Edit Budget Page")) {
                        Spacer()
                        Image(systemName: "square.and.pencil")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(10)
                                .background(Color.white.opacity(1))
                                .clipShape(Circle())
                        
                                            }
                }
                
                //PROGRESS BAR
                ProgressView(value: Double(currentSpent), total: Double(totalBudget))
                    .scaleEffect(x: 1, y: 3, anchor: .center)
                    .colorInvert()
                
                Text("Rp. \(currentSpent) / Rp. \(totalBudget)")
                    .font(.headline)
            }
            
            HStack(spacing: 16) {
    //CORTISOL PREVIEW
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.1))
                    VStack {
                        Text("Squeaky level :")
                            .font(.footnote)
                            .bold()
                            .padding(.horizontal, 16)
                            .padding(.top, 1)
                        ZStack{
                            Image("Meter")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 80)
                                .padding(.top, 55)
                            
                            Image("Needle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .rotationEffect(.degrees(-90 + (spentRatio * 180)), anchor: .bottom)
                                .offset(y: 40)
                            
                            Image("Pet lvl 1")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 90)
                            .offset(y: -20)
                            
                        }
                        
                        
                    }
                    
                }
                
                .aspectRatio(1, contentMode: .fit)
                
    //PIE CHART PREVIEW
                NavigationLink(destination: Text("Bigger Pie Chart")) {
                    ZStack {
                    RoundedRectangle(cornerRadius: 16)
    .fill(Color.white)
    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                                
    
    Chart(dummyExpenses) { expense in
        SectorMark(
        angle: .value("Spent", expense.amount),
        innerRadius: .ratio(0.0), //hole inside pie
        angularInset: 0.5 //gap between slices
        )
        .foregroundStyle(expense.color)
        .annotation(position: .overlay)
        {Text(expense.icon)
        .font(.title2)}
    }
        .padding(10)
    }
        .aspectRatio(1, contentMode: .fit)
    }
    }
            VStack(alignment: .leading, spacing: 10) {
                
    HStack {
        Text("Saving goals 🥳")
        .font(.body)
        .bold()
    NavigationLink(destination: Text("Add Saving Goal Page")) {
        Spacer()
            
            Image(systemName: "plus")
                .font(.headline)
                .foregroundColor(.black)
                .padding(10)
                .background(Color.white.opacity(1))
                .clipShape(Circle())
        
                            }
                        }
                        
let sortedGoals = dummyGoals.sorted(by: { $0.isPriority && !$1.isPriority })
                        
    ForEach(sortedGoals) { goal in
    VStack(alignment: .leading, spacing: 8) {
        Text(goal.title)
            .font(.subheadline)
            .bold()
            .foregroundColor(.black)
                                
        ProgressView(value: goal.currentSaved, total: goal.targetAmount)
                        .tint(.black)
                        .scaleEffect(x: 1, y: 3, anchor: .center)
                        .padding(.vertical, 4)

                }
            }
                    }
                    .padding(20)
                    .background(Color.yellow)
                    .cornerRadius(16)
        }
        
        .padding(20) //MARGIN
    }
}
    #Preview {
        OverviewView()
    }

struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
    let icon: String
}
//NANTI DIUBAH WAKTU TRANSACTION LIST UDAH JADI
let dummyExpenses: [ExpenseCategory] = [
    ExpenseCategory(name: "Food", amount: 55000, color: Color.yellow, icon: "🍔"),
    ExpenseCategory(name: "Entertainment", amount: 40000, color: Color.teal, icon: "🎬"),
    ExpenseCategory(name: "Social", amount: 75000, color: Color.orange, icon: "🥂")
]
struct OverviewSavingGoal: Identifiable {
    let id = UUID()
    let title: String
    let currentSaved: Double
    let targetAmount: Double
    let isPriority: Bool
}

//
//  EditTransactionView.swift
//  Squeaky
//
//  Created by Kevin William Faith on 09/04/26.
//

import SwiftUI
import SwiftData

struct EditTransactionView: View {
    // buat nutup sheet edit
    @Environment(\.dismiss) private var dismiss

    // akses ke swiftdata
    // dipakai buat save perubahan transaction
    @Environment(\.modelContext) private var modelContext

    // ini transaction yang dipilih dari list dan mau diedit
    let transaction: Transaction

    // ambil semua category dari swiftdata
    // nanti dipakai buat picker category
    @Query(sort: \Category.name) private var categories: [Category]

    // state lokal buat nampung isi form edit
    // jadi user edit dulu di sini, baru nanti disimpan ke data asli
    @State private var title: String
    @State private var amountText: String
    @State private var selectedType: TransactionType
    @State private var selectedCategoryName: String
    @State private var selectedDate: Date
    @State private var note: String

    // init dipakai buat ngisi form dengan data lama
    // jadi pas sheet edit kebuka, fieldnya langsung keisi
    init(transaction: Transaction) {
        self.transaction = transaction
        _title = State(initialValue: transaction.title)
        _amountText = State(initialValue: NSDecimalNumber(decimal: transaction.amount).stringValue)
        _selectedType = State(initialValue: transaction.type)
        _selectedCategoryName = State(initialValue: transaction.category?.name ?? "")
        _selectedDate = State(initialValue: transaction.date)
        _note = State(initialValue: transaction.note ?? "")
    }

    // ini category yang muncul cuma yang sesuai type
    // kalau income ya category income aja
    // kalau expense ya category expense aja
    private var filteredCategories: [Category] {
        let targetType: CategoryType = selectedType == .income ? .income : .expense
        return categories.filter { $0.type == targetType }
    }

    var body: some View {
        NavigationStack {
            Form {
                
                    // field judul transaksi
                    TextField("Title", text: $title)
                    
                    // field amount
                    // pakai text biar gampang diolah dulu sebelum diubah jadi decimal
                    TextField("Amount", text: $amountText)
                        .keyboardType(.numberPad)
                    
                    // picker type income / expense
                    Picker(selection: $selectedType) {
                        Text("Income").tag(TransactionType.income)
                        Text("Expense").tag(TransactionType.expense)
                    } label: {
                        Label {
                            Text("Type")
                        } icon: {
                            Image(systemName: "arrow.up.arrow.down")
                                .foregroundStyle(.darklilac)
                        }
                    }
                    // kalau type berubah, category ikut di-reset biar cocok
                    .onChange(of: selectedType) { _, _ in
                        selectedCategoryName = filteredCategories.first?.name ?? ""
                    }
                    
                    // picker category sesuai type
                    Picker(selection: $selectedCategoryName) {
                        ForEach(filteredCategories, id: \.id) { category in
                            Text(category.name).tag(category.name)
                        }
                    } label: {
                        Label {
                            Text("Category")
                        } icon: {
                            Image (systemName: "tag")
                                .foregroundStyle(.darklilac)
                        }
                    }
                    
                    // pilih tanggal
                    DatePicker(selection: $selectedDate, displayedComponents: [.date]) {
                        Label {
                            Text("Date")
                        } icon: {
                            Image (systemName: "calendar")
                                .foregroundStyle(.darklilac)
                        }
                    }
            }
            .scrollContentBackground(.hidden)
            
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!canSave)
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
                }
            }
            // kalau category kosong pas pertama kebuka, isi default dengan category pertama yang valid
            .onAppear {
                if selectedCategoryName.isEmpty {
                    selectedCategoryName = filteredCategories.first?.name ?? ""
                }
            }
        }
        .background(Color.lemon.opacity(0.25).ignoresSafeArea())
    }

    // validasi sederhana biar tombol save cuma aktif kalau input masuk akal
    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Decimal(string: cleanedAmount) != nil &&
        !selectedCategoryName.isEmpty
    }

    // bersihin format amount
    // misal kalau ada titik / koma dihapus dulu
    private var cleanedAmount: String {
        amountText
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // ini function utama buat update transaction lama
    private func saveChanges() {
        guard let newAmount = Decimal(string: cleanedAmount) else { return }

        let selectedCategory = filteredCategories.first { $0.name == selectedCategoryName }

        // ini bagian update object transaction yang lama
        // bukan bikin transaction baru
        transaction.title = title
        transaction.amount = newAmount
        transaction.type = selectedType
        transaction.date = selectedDate
        transaction.note = note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note
        transaction.category = selectedCategory

        do {
            // save perubahan ke swiftdata
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to update transaction: \(error)")
        }
    }
}

#Preview {
    EditTransactionView(
        transaction: Transaction(
            title: "Sample",
            amount: 25000,
            type: .expense,
            date: .now,
            note: "Lunch",
            category: nil
        )
    )
    .modelContainer(for: [Category.self, Transaction.self], inMemory: true)
}

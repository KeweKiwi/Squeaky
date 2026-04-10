//
//  AddTransactionView.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//


import SwiftUI
import SwiftData

struct AddTransactionView: View {
    // ini buat nutup sheet add transaction
    @Environment(\.dismiss) private var dismiss

    // ini pintu akses ke swiftdata
    // dipakai buat insert dan save transaction baru
    @Environment(\.modelContext) private var modelContext

    // ini ambil semua category dari database
    // sudah otomatis diurutkan berdasarkan nama karena pakai sort: \Category.name
    @Query(sort: \Category.name) private var categories: [Category]

    // ini dipakai buat ngatur field mana yang lagi aktif
    @FocusState private var focusedField: Field?

    // state form sementara
    // data user disimpan dulu di sini sebelum akhirnya disave ke database
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategoryName: String = ""
    @State private var note: String = ""
    @State private var amountText: String = ""
    @State private var selectedDate: Date = .now
    @State private var showDatePickerSheet = false

    // enum kecil buat nandain focus textfield
    enum Field {
        case note
        case amount
    }

    // ini nyaring category sesuai type
    // karena categories dari @Query sudah urut abjad, di sini cukup filter aja
    private var filteredCategories: [Category] {
        let targetType: CategoryType = selectedType == .expense ? .expense : .income
        return categories.filter { $0.type == targetType }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // background utama layar
            Color(.systemGray6)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                // segmented control native ios
                segmentedTypeSwitcher
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                // area category bisa discroll
                ScrollView {
                    VStack(spacing: 20) {
                        categoryGrid
                            .padding(.top, 24)

                        // spacer ini biar grid gak ketiban panel bawah
                        Spacer(minLength: 260)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }

            // panel bawah buat input utama
            inputPanel
        }
        .onAppear {
            // pas pertama buka, pilih category pertama yang valid
            syncDefaultCategory()

            // langsung fokus ke note biar user bisa langsung ngetik
            focusedField = .note
        }
        .sheet(isPresented: $showDatePickerSheet) {
            NavigationStack {
                VStack {
                    // datepicker native apple
                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .padding()

                    Spacer()
                }
                .navigationTitle("Choose Date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            showDatePickerSheet = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }

    // segmented control buat pilih expense / income
    private var segmentedTypeSwitcher: some View {
        Picker("Type", selection: $selectedType) {
            Text("Expense").tag(TransactionType.expense)
            Text("Income").tag(TransactionType.income)
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedType) { _, _ in
            // kalau type berubah, category default ikut disesuaikan
            syncDefaultCategory()
        }
    }

    // grid category
    private var categoryGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 18), count: 4)

        return LazyVGrid(columns: columns, spacing: 26) {
            ForEach(filteredCategories, id: \.id) { category in
                Button {
                    // simpan nama category yang dipilih user
                    selectedCategoryName = category.name
                } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            // kasih highlight kalau category sedang dipilih
                            Circle()
                                .fill(selectedCategoryName == category.name ? Color.black.opacity(0.08) : Color.clear)
                                .frame(width: 60, height: 60)

                            Text(categoryEmoji(for: category.name))
                                .font(.system(size: 36))
                        }

                        Text(category.name)
                            .font(.caption)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // panel bawah buat note, amount, date, dan tombol save
    private var inputPanel: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // field note
                TextField("note", text: $note)
                    .focused($focusedField, equals: .note)
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())

                // field amount
                // disimpan sebagai string dulu biar gampang dibersihin
                TextField("Rp.", text: $amountText)
                    .focused($focusedField, equals: .amount)
                    .keyboardType(.numberPad)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .frame(height: 44)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                // tombol tanggal
                Button {
                    showDatePickerSheet = true
                } label: {
                    Text(todayLabel)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 18)
                        .frame(height: 40)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                }

                // tombol save cepat
                Button {
                    saveTransaction()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(canSave ? Color.black : Color.gray.opacity(0.5))
                        .clipShape(Circle())
                }
                .disabled(!canSave)

                Spacer()
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 28)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.themeYellow)
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }

    // label tanggal
    // kalau hari ini ya tampil "Today"
    // kalau bukan, tampilkan format tanggal singkat
    private var todayLabel: String {
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter.string(from: selectedDate)
        }
    }

    // validasi sederhana biar tombol save cuma aktif kalau input masuk akal
    private var canSave: Bool {
        !selectedCategoryName.isEmpty &&
        !amountText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Decimal(string: cleanedAmount) != nil
    }

    // bersihin amount text
    // misalnya titik dan koma dihapus dulu sebelum diubah ke decimal
    private var cleanedAmount: String {
        amountText
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // pilih category default pertama sesuai type yang sedang aktif
    private func syncDefaultCategory() {
        if let first = filteredCategories.first {
            selectedCategoryName = first.name
        } else {
            selectedCategoryName = ""
        }
    }

    // function utama buat bikin transaction baru lalu simpan ke swiftdata
    private func saveTransaction() {
        guard let amount = Decimal(string: cleanedAmount), amount > 0 else { return }

        let selectedCategory = filteredCategories.first { $0.name == selectedCategoryName }

        let transaction = Transaction(
            // kalau note kosong, title pakai nama category
            title: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? selectedCategoryName : note,
            amount: amount,
            type: selectedType,
            date: selectedDate,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note,
            category: selectedCategory
        )

        // masukin transaction ke context
        modelContext.insert(transaction)

        do {
            // simpan permanen ke database
            try modelContext.save()

            // kalau berhasil, tutup sheet
            dismiss()
        } catch {
            print("Failed to save transaction: \(error)")
        }
    }

    // helper emoji buat category
    private func categoryEmoji(for name: String) -> String {
        switch name.lowercased() {
        case "education": return "📚"
        case "food": return "🍔"
        case "transport": return "🚕"
        case "gift": return "🎁"
        case "beauty": return "💄"
        case "clothes", "clothing": return "👚"
        case "social": return "🥂"
        case "medical": return "🩺"
        case "debt": return "💳"
        case "entertainment": return "🎬"
        case "daily": return "🛒"
        case "other": return "➕"
        case "salary": return "💰"
        case "allowance": return "💸"
        case "bonus": return "🎉"
        case "freelance": return "🧑‍💻"
        default: return "🧾"
        }
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(for: [Category.self, Transaction.self], inMemory: true)
}

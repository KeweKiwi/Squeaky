import SwiftUI
import SwiftData

// ini buat filter segmented control
// jadi user bisa pilih mau lihat all, income, atau expense
enum TransactionFilter: String, CaseIterable {
    case all = "All"
    case income = "Income"
    case expense = "Expense"
}

struct TransactionListFlow: View {
    // ini pintu akses ke swiftdata
    // dipakai buat delete, save, dan hal lain yang ngubah data
    @Environment(\.modelContext) private var modelContext

    // ini ambil semua transaction dari swiftdata
    // terus langsung diurutkan dari tanggal paling baru
    @Query(sort: \Transaction.date, order: .reverse)
    private var transactions: [Transaction]

    // state ui
    // dipakai buat nyimpen kondisi tampilan sementara
    @State private var isSelectionMode = false
    @State private var selectedItems = Set<UUID>()
    @State private var showDeleteAlert = false
    @State private var selectedSegment: TransactionFilter = .all
    @State private var expandedSections = Set<String>()

    // ini buat pilih bulan dan tahun
    // defaultnya langsung ambil bulan dan tahun sekarang
    @State private var selectedMonth: String = Calendar.current.monthSymbols[Calendar.current.component(.month, from: .now) - 1]
    @State private var selectedYear: Int = Calendar.current.component(.year, from: .now)
    @State private var showDatePicker = false

    // ini dipakai buat simpan transaction yang mau diedit
    // nanti kalau row dipencet, isi state ini lalu munculin edit sheet
    @State private var selectedTransactionToEdit: Transaction?

    // daftar nama bulan
    let months = Calendar.current.monthSymbols

    // daftar tahun buat picker
    let years = Array(2020...2030)

    // ini filter utama
    // pertama dia filter dulu berdasarkan bulan + tahun
    // habis itu baru difilter lagi berdasarkan all / income / expense
    private var filteredTransactions: [Transaction] {
        let calendar = Calendar.current

        guard let selectedMonthIndex = months.firstIndex(of: selectedMonth) else {
            return []
        }

        let targetMonth = selectedMonthIndex + 1

        let monthFiltered = transactions.filter { transaction in
            let transactionMonth = calendar.component(.month, from: transaction.date)
            let transactionYear = calendar.component(.year, from: transaction.date)

            return transactionMonth == targetMonth && transactionYear == selectedYear
        }

        switch selectedSegment {
        case .all:
            return monthFiltered
        case .income:
            return monthFiltered.filter { $0.type == .income }
        case .expense:
            return monthFiltered.filter { $0.type == .expense }
        }
    }

    // ini buat ngelompokkan transaction per tanggal
    // jadi nanti tampilannya per hari, bukan list panjang semua
    private var groupedTransactions: [(dateKey: String, items: [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            formattedSectionDate(transaction.date)
        }

        return grouped
            .map { (dateKey: $0.key, items: $0.value.sorted { $0.date > $1.date }) }
            .sorted {
                guard
                    let firstDate = $0.items.first?.date,
                    let secondDate = $1.items.first?.date
                else { return false }

                return firstDate > secondDate
            }
    }

    var body: some View {
        ZStack {
            VStack(spacing: -30) {
                headerSection

                ScrollView {
                    VStack(spacing: 10) {
                        if groupedTransactions.isEmpty {
                            ContentUnavailableView(
                                "No Transactions",
                                systemImage: "tray",
                                description: Text(emptyStateText)
                            )
                            .padding(.top, 40)
                        } else {
                            ForEach(groupedTransactions, id: \.dateKey) { group in
                                dailyGroupView(group: group)
                            }
                        }
                    }
                }
                // pas screen kebuka, semua section langsung dibuka
                .onAppear {
                    expandAllSections()
                }
                // kalau bulan berubah, section dibuka lagi biar data baru langsung kelihatan
                .onChange(of: selectedMonth) { _, _ in
                    expandAllSections()
                }
                .onChange(of: selectedYear) { _, _ in
                    expandAllSections()
                }
                .onChange(of: selectedSegment) { _, _ in
                    expandAllSections()
                }
            }

            // kalau lagi mode select, munculin tombol trash melayang
            if isSelectionMode {
                trashIconButton
            }

            // ini popup konfirmasi delete
            if showDeleteAlert {
                deleteAlertOverlay
            }
        }
        .edgesIgnoringSafeArea(.bottom)

        // ini buat seed data awal
        // category, budget, sama transaction dummy
        .task {
            SeedData.seedCategoriesIfNeeded(context: modelContext)
            BudgetSeedData.seedBudgetIfNeeded(context: modelContext)
            TransactionSeedData.seedTransactionsIfNeeded(context: modelContext)
            expandAllSections()
        }

        // sheet buat pilih bulan dan tahun
        .sheet(isPresented: $showDatePicker) {
            datePickerModal
        }

        // sheet buat edit transaction
        .sheet(item: $selectedTransactionToEdit) { transaction in
            EditTransactionView(transaction: transaction)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 15) {
            HStack {
                Spacer()

                // tombol select / cancel
                // kalau select aktif, user bisa pilih item buat dihapus
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
                .cornerRadius(15)
            }
            .padding(.horizontal)
            
                Text("Transaction List")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 7)

            HStack(spacing: 20) {
                // pindah ke bulan sebelumnya
                Button {
                    withAnimation { changeMonth(by: -1) }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding(5)
                }

                // tekan teks bulan buat buka picker modal
                Button {
                    showDatePicker = true
                } label: {
                    Text(selectedMonth + " " + String(selectedYear))
                        .font(.title3)
                        .foregroundColor(.black)
                }

                // pindah ke bulan berikutnya
                Button {
                    withAnimation { changeMonth(by: 1) }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .padding(5)
                }
            }

            // segmented control native apple
            // buat filter all / income / expense
            Picker("Filter", selection: $selectedSegment) {
                ForEach(TransactionFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .onChange(of: selectedSegment) { _, _ in
                selectedItems.removeAll()
            }
        }
        .padding(.top, 55)
        .padding(.bottom, 32)
        .background(Color.themeYellow)
        .clipShape(RoundedCorner(radius: 55, corners: [.bottomLeft, .bottomRight]))
        .ignoresSafeArea(edges: .top)
    }

    private var datePickerModal: some View {
        NavigationView {
            VStack {
                HStack(spacing: 0) {
                    // picker bulan
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(months, id: \.self) { month in
                            Text(month).tag(month)
                        }
                    }
                    .pickerStyle(.wheel)

                    // picker tahun
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year)).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Select Month and Year")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showDatePicker = false
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .presentationDetents([.height(300)])
    }

    private func dailyGroupView(group: (dateKey: String, items: [Transaction])) -> some View {
        // ini ngecek section tanggal ini sedang kebuka atau nggak
        let isExpanded = expandedSections.contains(group.dateKey)

        return VStack(spacing: 0) {
            HStack {
                Text(group.dateKey)
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            }
            .padding()
            .background(Color.themePurple)

            // kalau header tanggal dipencet, section dibuka / ditutup
            .onTapGesture {
                toggleSection(group.dateKey)
            }

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(group.items, id: \.id) { item in
                        HStack {
                            // checkbox cuma muncul kalau select mode aktif
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

                            // icon category
                            ZStack {
                                Circle()
                                    .fill(categoryColor(for: item).opacity(0.2))
                                    .frame(width: 35, height: 35)
                                Text(categoryEmoji(for: item))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.body)

                                // note cuma tampil kalau ada isi
                                if let note = item.note, !note.isEmpty {
                                    Text(note)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            Text(currency(item.amount))
                                .fontWeight(.semibold)
                        }
                        .padding()

                        // bikin seluruh row bisa dipencet
                        // kalau bukan mode select, tap row = edit
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if !isSelectionMode {
                                selectedTransactionToEdit = item
                            }
                        }

                        Divider().padding(.leading, isSelectionMode ? 50 : 20)
                    }

                    groupFooter(for: group.items)
                        .padding()
                }
            }
        }
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }

    
    // @ViewBuilder dipakai supaya function yang bikin ui bisa return beberapa kemungkinan tampilan dan tetap dianggap valid oleh SwiftUI.
    @ViewBuilder
    private func groupFooter(for items: [Transaction]) -> some View {
        switch selectedSegment {
        case .all:
            HStack {
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 8) {
                        Text("Total Income")
                            .foregroundColor(.gray)
                        Text(currency(totalIncome(for: items)))
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }

                    HStack(spacing: 8) {
                        Text("Total Expense")
                            .foregroundColor(.gray)
                        Text(currency(totalExpense(for: items)))
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
            }

        case .income:
            HStack {
                Spacer()
                Text("Total Income")
                    .foregroundColor(.gray)
                Text(currency(totalIncome(for: items)))
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }

        case .expense:
            HStack {
                Spacer()
                Text("Total Expense")
                    .foregroundColor(.gray)
                Text(currency(totalExpense(for: items)))
                    .fontWeight(.bold)
                    .foregroundColor(.red)
            }
        }
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
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Are you sure you want to delete?")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                HStack(spacing: 15) {
                    Button("No") {
                        showDeleteAlert = false
                        isSelectionMode = false
                        selectedItems.removeAll()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    .foregroundColor(.black)

                    Button("Yes") {
                        deleteAction()
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

    private var emptyStateText: String {
        switch selectedSegment {
        case .all:
            return "No transactions yet."
        case .income:
            return "No income transactions yet."
        case .expense:
            return "No expense transactions yet."
        }
    }

    // format tanggal section
    // contoh: wednesday, 2
    private func formattedSectionDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d"
        return formatter.string(from: date)
    }

    // total income untuk 1 group tanggal
    private func totalIncome(for items: [Transaction]) -> Decimal {
        items
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    // total expense untuk 1 group tanggal
    private func totalExpense(for items: [Transaction]) -> Decimal {
        items
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    // format decimal jadi rupiah
    private func currency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "Rp0"
    }

    // emoji berdasarkan nama category
    private func categoryEmoji(for transaction: Transaction) -> String {
        switch transaction.category?.name.lowercased() {
        case "food": return "🍔"
        case "clothing", "clothes": return "👚"
        case "transport": return "🚗"
        case "beauty": return "💄"
        case "entertainment": return "🎬"
        case "gift": return "🎁"
        case "medical": return "🩺"
        case "debt": return "💳"
        case "daily": return "🛒"
        case "salary": return "💰"
        case "allowance": return "💸"
        case "bonus": return "🎉"
        case "freelance": return "🧑‍💻"
        default: return "🧾"
        }
    }

    // warna bulatan icon berdasarkan category
    private func categoryColor(for transaction: Transaction) -> Color {
        switch transaction.category?.name.lowercased() {
        case "food": return .orange
        case "clothing", "clothes": return .purple
        case "transport": return .blue
        case "beauty": return .pink
        case "entertainment": return .indigo
        case "gift": return .red
        case "medical": return .green
        case "debt": return .gray
        case "daily": return .yellow
        case "salary", "allowance", "bonus", "freelance": return .green
        default: return .gray
        }
    }

    // buka / tutup section tanggal
    private func toggleSection(_ key: String) {
        if expandedSections.contains(key) {
            expandedSections.remove(key)
        } else {
            expandedSections.insert(key)
        }
    }

    // bikin semua section tanggal langsung kebuka
    private func expandAllSections() {
        expandedSections = Set(groupedTransactions.map { $0.dateKey })
    }

    // pindah bulan dengan tombol kiri kanan
    // kalau lewat desember / januari, tahunnya ikut berubah
    private func changeMonth(by amount: Int) {
        if let currentIndex = months.firstIndex(of: selectedMonth) {
            var newIndex = currentIndex + amount

            if newIndex > 11 {
                newIndex = 0
                selectedYear += 1
            } else if newIndex < 0 {
                newIndex = 11
                selectedYear -= 1
            }

            selectedMonth = months[newIndex]
        }
    }

    // delete semua transaction yang dipilih
    private func deleteAction() {
        let itemsToDelete = transactions.filter { selectedItems.contains($0.id) }

        for item in itemsToDelete {
            modelContext.delete(item)
        }

        try? modelContext.save()

        showDeleteAlert = false
        isSelectionMode = false
        selectedItems.removeAll()
    }
}

extension Color {
    static let themeYellow = Color(pastelyellow)
    static let themePurple = Color(pastellilac)
}

#Preview {
    TransactionListFlow()
}

import AppIntents


// fungsi app enum itu biar bisa dipakai di shortcuts, siri dll yg berhubungan dengan app intent
// case iterable itu untuk menampilkan semua case yang dia punya (cth: ShortcutTransactionType.allCases)

enum ShortcutTransactionType: String, AppEnum, CaseIterable {
    case income
    case expense

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Transaction Type")

    static var caseDisplayRepresentations: [ShortcutTransactionType: DisplayRepresentation] = [
        .income: "Income",
        .expense: "Expense"
    ]
}

enum ShortcutCategoryOption: String, AppEnum, CaseIterable {
    case food
    case clothing
    case transport
    case beauty
    case entertainment
    case gift
    case medical
    case debt
    case daily

    case salary
    case allowance
    case bonus
    case freelance

    case other

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Category")

    static var caseDisplayRepresentations: [ShortcutCategoryOption: DisplayRepresentation] = [
        .food: "Food",
        .clothing: "Clothing",
        .transport: "Transport",
        .beauty: "Beauty",
        .entertainment: "Entertainment",
        .gift: "Gift",
        .medical: "Medical",
        .debt: "Debt",
        .daily: "Daily",
        .salary: "Salary",
        .allowance: "Allowance",
        .bonus: "Bonus",
        .freelance: "Freelance",
        .other: "Other"
    ]
}

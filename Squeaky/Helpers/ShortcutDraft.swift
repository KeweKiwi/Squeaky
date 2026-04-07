////
////  ShortcutDraft.swift
////  Squeaky
////
////  Created by Kevin William Faith on 05/04/26.
////
//
//import Foundation
//
//struct ShortcutTransactionDraft: Codable, Identifiable {
//    let id: UUID
//    let title: String
//    let amount: Double
//    let type: String
//    let category: String
//    let date: Date
//}
//
//enum ShortcutDraftStore {
//    private static let key = "shortcut_transaction_draft"
//
//    static func save(_ draft: ShortcutTransactionDraft) {
//        guard let data = try? JSONEncoder().encode(draft) else { return }
//        UserDefaults.standard.set(data, forKey: key)
//    }
//
//    static func consume() -> ShortcutTransactionDraft? {
//        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
//        UserDefaults.standard.removeObject(forKey: key)
//        return try? JSONDecoder().decode(ShortcutTransactionDraft.self, from: data)
//    }
//}

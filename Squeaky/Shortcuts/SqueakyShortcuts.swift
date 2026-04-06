//
//  SqueakyShortcuts.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import AppIntents

struct SqueakyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddTransactionFromShortcutIntent(),
            phrases: [
                "Add transaction in \(.applicationName)",
                "Log expense in \(.applicationName)",
                "Log income in \(.applicationName)"
            ],
            shortTitle: "Add Transaction",
            systemImageName: "plus.circle"
        )
    }
}

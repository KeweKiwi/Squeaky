//
//  SqueakyApp.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import SwiftUI
import SwiftData

@main
struct SqueakyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(SharedModelContainer.container)
    }
}

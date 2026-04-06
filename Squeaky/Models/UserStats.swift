//
//  UserStats.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import Foundation
import SwiftData

enum CortisolStatus: String, Codable, CaseIterable {
    case low
    case medium
    case high
}

@Model
final class UserStats {
    var exp: Int
    var level: Int

    init(exp: Int = 0, level: Int = 1) {
        self.exp = exp
        self.level = level
    }
}

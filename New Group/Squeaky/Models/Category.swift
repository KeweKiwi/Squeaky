//
//  Category.swift
//  Squeaky
//
//  Created by Kevin William Faith on 05/04/26.
//

import Foundation
import SwiftData

enum CategoryType: String, Codable, CaseIterable {
    case income
    case expense
}

@Model
final class Category {
    var id: UUID
    var name: String
    var type: CategoryType

    init(id: UUID = UUID(), name: String, type: CategoryType) {
        self.id = id
        self.name = name
        self.type = type
    }
}


//final class Category = cetakan / blueprint untuk membuat object bertipe Category
//var name dan var type = property yang dimiliki setiap object Category
//init(name:type:) = aturan saat object Category dibuat, yaitu harus diberi nilai name dan type

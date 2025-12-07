//
//  Credit.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//

import SwiftUI
import SwiftData

// MARK: - Credit Model

@Model
final class Credit {
    var id: UUID
    var title: String
    var amount: Double
    var source: String
    var date: Date
    var notes: String
    
    init(id: UUID = UUID(), title: String, amount: Double, source: String, date: Date, notes: String = "") {
        self.id = id
        self.title = title
        self.amount = amount
        self.source = source
        self.date = date
        self.notes = notes
    }
}

struct CreditSource: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}


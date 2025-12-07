//
//  Expense_TrackerApp.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//

import SwiftUI
import SwiftData

@main
struct Expense_TrackerApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
               
        }
        .modelContainer(for: [Expense.self, SplitRoom.self, RoomMember.self, SplitExpense.self,Credit.self,WishlistItem.self])
    }
}

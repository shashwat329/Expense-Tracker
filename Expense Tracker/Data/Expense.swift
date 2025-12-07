//
//  Expense.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//


import SwiftUI
import SwiftData
import Charts

// MARK: - Models

@Model
final class Expense {
    var id: UUID
    var title: String
    var amount: Double
    var category: String
    var date: Date
    var notes: String
    
    init(id: UUID = UUID(), title: String, amount: Double, category: String, date: Date, notes: String = "") {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
    }
}

struct Category: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

// MARK: - View Models

@Observable
class ExpenseViewModel {
    var expenses: [Expense] = []
    var credits: [Credit] = []
    var searchText = ""
    var sortOption: SortOption = .date
    
    enum SortOption {
        case date, amount
    }
    
    let categories = [
        Category(name: "Food", icon: "fork.knife", color: .orange),
        Category(name: "Shopping", icon: "cart.fill", color: .blue),
        Category(name: "Travel", icon: "airplane", color: .green),
        Category(name: "Bills", icon: "doc.text.fill", color: .red),
        Category(name: "Entertainment", icon: "tv.fill", color: .purple),
        Category(name: "Health", icon: "heart.fill", color: .pink),
        Category(name: "Education", icon: "book.fill", color: .indigo),
        Category(name: "Others", icon: "ellipsis.circle.fill", color: .gray)
    ]
    
    let creditSources = [
        CreditSource(name: "Salary", icon: "briefcase.fill", color: .green),
        CreditSource(name: "Freelance", icon: "laptopcomputer", color: .blue),
        CreditSource(name: "Investment", icon: "chart.line.uptrend.xyaxis", color: .purple),
        CreditSource(name: "Gift", icon: "gift.fill", color: .pink),
        CreditSource(name: "Other", icon: "ellipsis.circle.fill", color: .gray)
    ]
    
    var filteredExpenses: [Expense] {
        var result = expenses
        
        if !searchText.isEmpty {
            result = result.filter { expense in
                expense.title.localizedCaseInsensitiveContains(searchText) ||
                expense.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch sortOption {
        case .date:
            return result.sorted { $0.date > $1.date }
        case .amount:
            return result.sorted { $0.amount > $1.amount }
        }
    }
    
    func categoryColor(for categoryName: String) -> Color {
        categories.first(where: { $0.name == categoryName })?.color ?? .gray
    }
    
    func categoryIcon(for categoryName: String) -> String {
        categories.first(where: { $0.name == categoryName })?.icon ?? "ellipsis.circle.fill"
    }
    
    func expenses(for date: Date) -> [Expense] {
        expenses.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func totalAmount(for date: Date) -> Double {
        expenses(for: date).reduce(0) { $0 + $1.amount }
    }
    
    func expenses(for category: String) -> [Expense] {
        expenses.filter { $0.category == category }
    }
    
    var todayTotal: Double {
        expenses(for: Date()).reduce(0) { $0 + $1.amount }
    }
    
    var weekTotal: Double {
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return expenses.filter { $0.date >= startOfWeek }.reduce(0) { $0 + $1.amount }
    }
    
    var monthTotal: Double {
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        return expenses.filter { $0.date >= startOfMonth }.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Credit Computed Properties
    
    var filteredCredits: [Credit] {
        var result = credits
        
        if !searchText.isEmpty {
            result = result.filter { credit in
                credit.title.localizedCaseInsensitiveContains(searchText) ||
                credit.source.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        switch sortOption {
        case .date:
            return result.sorted { $0.date > $1.date }
        case .amount:
            return result.sorted { $0.amount > $1.amount }
        }
    }
    
    func creditSourceColor(for sourceName: String) -> Color {
        creditSources.first(where: { $0.name == sourceName })?.color ?? .gray
    }
    
    func creditSourceIcon(for sourceName: String) -> String {
        creditSources.first(where: { $0.name == sourceName })?.icon ?? "ellipsis.circle.fill"
    }
    
    func credits(for date: Date) -> [Credit] {
        credits.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func totalCredit(for date: Date) -> Double {
        credits(for: date).reduce(0) { $0 + $1.amount }
    }
    
    func credits(for source: String) -> [Credit] {
        credits.filter { $0.source == source }
    }
    
    var todayCredit: Double {
        credits(for: Date()).reduce(0) { $0 + $1.amount }
    }
    
    var weekCredit: Double {
        let startOfWeek = Calendar.current.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        return credits.filter { $0.date >= startOfWeek }.reduce(0) { $0 + $1.amount }
    }
    
    var monthCredit: Double {
        let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
        return credits.filter { $0.date >= startOfMonth }.reduce(0) { $0 + $1.amount }
    }
    
    var totalCredit: Double {
        credits.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    var netBalance: Double {
        totalCredit - totalExpenses
    }
    
    var todayNetBalance: Double {
        todayCredit - todayTotal
    }
    
    var weekNetBalance: Double {
        weekCredit - weekTotal
    }
    
    var monthNetBalance: Double {
        monthCredit - monthTotal
    }
    
    // MARK: - Spending Rate Calculations
    
    var dailySpendingRate: Double {
        guard !expenses.isEmpty else { return 0 }
        let calendar = Calendar.current
        let oldestExpense = expenses.map { $0.date }.min() ?? Date()
        let daysSinceFirst = max(1, calendar.dateComponents([.day], from: oldestExpense, to: Date()).day ?? 1)
        return totalExpenses / Double(daysSinceFirst)
    }
    
    var weeklySpendingRate: Double {
        guard !expenses.isEmpty else { return 0 }
        let calendar = Calendar.current
        let oldestExpense = expenses.map { $0.date }.min() ?? Date()
        let weeksSinceFirst = max(1, calendar.dateComponents([.weekOfYear], from: oldestExpense, to: Date()).weekOfYear ?? 1)
        return totalExpenses / Double(weeksSinceFirst)
    }
    
    var monthlySpendingRate: Double {
        guard !expenses.isEmpty else { return 0 }
        let calendar = Calendar.current
        let oldestExpense = expenses.map { $0.date }.min() ?? Date()
        let monthsSinceFirst = max(1, calendar.dateComponents([.month], from: oldestExpense, to: Date()).month ?? 1)
        return totalExpenses / Double(monthsSinceFirst)
    }
    
    var burnRate: Double {
        guard netBalance > 0 && dailySpendingRate > 0 else { return 0 }
        return netBalance / dailySpendingRate
    }
    
    var savingsRate: Double {
        guard totalCredit > 0 else { return 0 }
        return (netBalance / totalCredit) * 100
    }
    
    var spendingVelocity: Double {
        guard expenses.count >= 2 else { return 0 }
        let sortedExpenses = expenses.sorted { $0.date < $1.date }
        let firstHalf = sortedExpenses.prefix(sortedExpenses.count / 2)
        let secondHalf = sortedExpenses.suffix(sortedExpenses.count / 2)
        
        let firstHalfTotal = firstHalf.reduce(0) { $0 + $1.amount }
        let secondHalfTotal = secondHalf.reduce(0) { $0 + $1.amount }
        
        guard firstHalfTotal > 0 else { return 0 }
        return ((secondHalfTotal - firstHalfTotal) / firstHalfTotal) * 100
    }
    
    func projectedBalance(days: Int) -> Double {
        return netBalance - (dailySpendingRate * Double(days))
    }
    
    func exportCSV() -> String {
        var csv = "Type,Date,Title,Category/Source,Amount,Notes\n"
        
        // Export expenses
        for expense in expenses.sorted(by: { $0.date > $1.date }) {
            let dateStr = DateFormatter.localizedString(from: expense.date, dateStyle: .short, timeStyle: .none)
            csv += "Expense,\(dateStr),\(expense.title),\(expense.category),\(expense.amount),\(expense.notes)\n"
        }
        
        // Export credits
        for credit in credits.sorted(by: { $0.date > $1.date }) {
            let dateStr = DateFormatter.localizedString(from: credit.date, dateStyle: .short, timeStyle: .none)
            csv += "Credit,\(dateStr),\(credit.title),\(credit.source),\(credit.amount),\(credit.notes)\n"
        }
        
        return csv
    }
}
// MARK: - Models

//@Model
//final class Expense {
//    var id: UUID
//    var title: String
//    var amount: Double
//    var category: String
//    var date: Date
//    var notes: String
//    
//    init(id: UUID = UUID(), title: String, amount: Double, category: String, date: Date, notes: String = "") {
//        self.id = id
//        self.title = title
//        self.amount = amount
//        self.category = category
//        self.date = date
//        self.notes = notes
//    }
//}

@Model
final class SplitRoom {
    var id: UUID
    var name: String
    var createdDate: Date
    var members: [RoomMember]
    var expenses: [SplitExpense]
    
    init(id: UUID = UUID(), name: String, createdDate: Date = Date(), members: [RoomMember] = [], expenses: [SplitExpense] = []) {
        self.id = id
        self.name = name
        self.createdDate = createdDate
        self.members = members
        self.expenses = expenses
    }
}

@Model
final class RoomMember {
    var id: UUID
    var name: String
    var phoneNumber: String
    var email: String
    
    init(id: UUID = UUID(), name: String, phoneNumber: String = "", email: String = "") {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
    }
}

@Model
final class SplitExpense {
    var id: UUID
    var title: String
    var amount: Double
    var paidBy: String // Member name
    var splitAmong: [String] // Member names
    var date: Date
    var notes: String
    
    init(id: UUID = UUID(), title: String, amount: Double, paidBy: String, splitAmong: [String], date: Date = Date(), notes: String = "") {
        self.id = id
        self.title = title
        self.amount = amount
        self.paidBy = paidBy
        self.splitAmong = splitAmong
        self.date = date
        self.notes = notes
    }
}

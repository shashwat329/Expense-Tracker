//
//  WishlistItem.swift
//  Expense Tracker
//
//  Created by shashwat singh on 07/12/25.
//
import SwiftUI
import SwiftData

@Model
final class WishlistItem {
    var id: UUID
    var title: String
    var price: Double
    var imageURL: String
    var notes: String
    var priority: String // High, Medium, Low
    var isPurchased: Bool
    var dateAdded: Date
    var targetDate: Date?
    var category: String
    
    init(id: UUID = UUID(), title: String, price: Double, imageURL: String = "", notes: String = "", priority: String = "Medium", isPurchased: Bool = false, dateAdded: Date = Date(), targetDate: Date? = nil, category: String = "Others") {
        self.id = id
        self.title = title
        self.price = price
        self.imageURL = imageURL
        self.notes = notes
        self.priority = priority
        self.isPurchased = isPurchased
        self.dateAdded = dateAdded
        self.targetDate = targetDate
        self.category = category
    }
}

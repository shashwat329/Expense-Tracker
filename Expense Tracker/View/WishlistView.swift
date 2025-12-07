//
//  WishlistView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 07/12/25.
//
import SwiftUI
import SwiftData

struct WishlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var wishlistItems: [WishlistItem]
    @State private var showingAddItem = false
    @State private var filterOption: FilterOption = .all
    @State private var sortOption: SortOption = .dateAdded
    @Bindable var viewModel: ExpenseViewModel
    
    enum FilterOption {
        case all, pending, purchased
    }
    
    enum SortOption {
        case dateAdded, price, priority
    }
    
    var filteredItems: [WishlistItem] {
        var items = wishlistItems
        
        switch filterOption {
        case .all:
            break
        case .pending:
            items = items.filter { !$0.isPurchased }
        case .purchased:
            items = items.filter { $0.isPurchased }
        }
        
        switch sortOption {
        case .dateAdded:
            return items.sorted { $0.dateAdded > $1.dateAdded }
        case .price:
            return items.sorted { $0.price > $1.price }
        case .priority:
            let priorityOrder = ["High": 0, "Medium": 1, "Low": 2]
            return items.sorted { 
                (priorityOrder[$0.priority] ?? 3) < (priorityOrder[$1.priority] ?? 3)
            }
        }
    }
    
    var totalWishlistValue: Double {
        wishlistItems.filter { !$0.isPurchased }.reduce(0) { $0 + $1.price }
    }
    
    var purchasedValue: Double {
        wishlistItems.filter { $0.isPurchased }.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary Section
                VStack(spacing: 12) {
                    Text("Net Balance")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    Text("₹\(viewModel.monthNetBalance, specifier: "%.2f")")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            viewModel.monthNetBalance >= 0 ?
                            LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [.red, .red.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                        )
                }
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Value")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("₹\(totalWishlistValue, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Purchased")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("₹\(purchasedValue, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
                
                // Filter and Sort
                HStack {
                    Menu {
                        Button("All Items") { filterOption = .all }
                        Button("Pending") { filterOption = .pending }
                        Button("Purchased") { filterOption = .purchased }
                    } label: {
                        Label(filterText, systemImage: "line.3.horizontal.decrease.circle")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button("Date Added") { sortOption = .dateAdded }
                        Button("Price") { sortOption = .price }
                        Button("Priority") { sortOption = .priority }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                Divider()
                
                // Wishlist Items
                if filteredItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.pink)
                        
                        Text("No Items Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add items you want to buy to your wishlist")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            showingAddItem = true
                        } label: {
                            Label("Add Item", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.pink.gradient)
                                .cornerRadius(12)
                        }
                    }
                    .padding(40)
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(filteredItems) { item in
                                WishlistItemCard(item: item)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Wishlist")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddItem = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddWishlistItemView()
            }
        }
    }
    
    var filterText: String {
        switch filterOption {
        case .all: return "All Items"
        case .pending: return "Pending"
        case .purchased: return "Purchased"
        }
    }
}

// MARK: - Wishlist Item Card

struct WishlistItemCard: View {
    @Environment(\.modelContext) private var modelContext
    let item: WishlistItem
    @State private var showingEdit = false
    
    var priorityColor: Color {
        switch item.priority {
        case "High": return .red
        case "Medium": return .orange
        case "Low": return .green
        default: return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Image placeholder
            ZStack {
                if item.imageURL.isEmpty {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(.secondary)
                } else {
                    // In a real app, load image from URL
                    Image(systemName: "photo.fill")
                        .font(.title)
                        .foregroundStyle(.blue)
                }
            }
            .frame(width: 70, height: 70)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.isPurchased)
                    .foregroundStyle(item.isPurchased ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    // Priority badge
                    Text(item.priority)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(priorityColor)
                        .cornerRadius(6)
                    
                    Text(item.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let targetDate = item.targetDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text("Target: \(targetDate, style: .date)")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("₹\(item.price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundStyle(item.isPurchased ? .green : .blue)
                
                Button {
                    withAnimation {
                        item.isPurchased.toggle()
                    }
                } label: {
                    Image(systemName: item.isPurchased ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(item.isPurchased ? .green : .secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
        .opacity(item.isPurchased ? 0.7 : 1.0)
        .contextMenu {
            Button {
                showingEdit = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button {
                withAnimation {
                    item.isPurchased.toggle()
                }
            } label: {
                Label(item.isPurchased ? "Mark as Pending" : "Mark as Purchased", systemImage: item.isPurchased ? "circle" : "checkmark.circle")
            }
            
            Button(role: .destructive) {
                modelContext.delete(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditWishlistItemView(item: item)
        }
    }
}

// MARK: - Add Wishlist Item View

struct AddWishlistItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var price = ""
    @State private var notes = ""
    @State private var priority = "Medium"
    @State private var category = "Others"
    @State private var hasTargetDate = false
    @State private var targetDate = Date()
    
    let priorities = ["High", "Medium", "Low"]
    let categories = ["Electronics", "Fashion", "Home", "Books", "Gadgets", "Sports", "Travel", "Others"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $title)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }
                
                Section("Category & Priority") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { pri in
                            HStack {
                                Circle()
                                    .fill(priorityColor(for: pri))
                                    .frame(width: 10, height: 10)
                                Text(pri)
                            }
                            .tag(pri)
                        }
                    }
                }
                
                Section {
                    Toggle("Set Target Date", isOn: $hasTargetDate)
                    
                    if hasTargetDate {
                        DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add to Wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(title.isEmpty || price.isEmpty)
                }
            }
        }
    }
    
    func priorityColor(for priority: String) -> Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        case "Low": return .green
        default: return .gray
        }
    }
    
    func addItem() {
        guard let priceValue = Double(price) else { return }
        
        let item = WishlistItem(
            title: title,
            price: priceValue,
            notes: notes,
            priority: priority,
            targetDate: hasTargetDate ? targetDate : nil,
            category: category
        )
        
        modelContext.insert(item)
        dismiss()
    }
}

// MARK: - Edit Wishlist Item View

struct EditWishlistItemView: View {
    @Environment(\.dismiss) private var dismiss
    let item: WishlistItem
    
    @State private var title = ""
    @State private var price = ""
    @State private var notes = ""
    @State private var priority = "Medium"
    @State private var category = "Others"
    @State private var hasTargetDate = false
    @State private var targetDate = Date()
    
    let priorities = ["High", "Medium", "Low"]
    let categories = ["Electronics", "Fashion", "Home", "Books", "Gadgets", "Sports", "Travel", "Others"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item Name", text: $title)
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                }
                
                Section("Category & Priority") {
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { pri in
                            HStack {
                                Circle()
                                    .fill(priorityColor(for: pri))
                                    .frame(width: 10, height: 10)
                                Text(pri)
                            }
                            .tag(pri)
                        }
                    }
                }
                
                Section {
                    Toggle("Set Target Date", isOn: $hasTargetDate)
                    
                    if hasTargetDate {
                        DatePicker("Target Date", selection: $targetDate, displayedComponents: .date)
                    }
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                    }
                }
            }
            .onAppear {
                title = item.title
                price = String(item.price)
                notes = item.notes
                priority = item.priority
                category = item.category
                hasTargetDate = item.targetDate != nil
                if let target = item.targetDate {
                    targetDate = target
                }
            }
        }
    }
    
    func priorityColor(for priority: String) -> Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        case "Low": return .green
        default: return .gray
        }
    }
    
    func saveItem() {
        guard let priceValue = Double(price) else { return }
        
        item.title = title
        item.price = priceValue
        item.notes = notes
        item.priority = priority
        item.category = category
        item.targetDate = hasTargetDate ? targetDate : nil
        
        dismiss()
    }
}

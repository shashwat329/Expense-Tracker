//
//  AddExpenseView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//
import SwiftUI
import SwiftData
import Charts

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let viewModel: ExpenseViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = "Food"
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(viewModel.categories, id: \.name) { category in
                            Label(category.name, systemImage: category.icon)
                                .tag(category.name)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let expense = Expense(
            title: title,
            amount: amountValue,
            category: selectedCategory,
            date: date,
            notes: notes
        )
        
        modelContext.insert(expense)
        dismiss()
    }
}

//
//  EditExpenseView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//
import SwiftUI
import SwiftData

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    let expense: Expense
    let viewModel: ExpenseViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedCategory = ""
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
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Expense")
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
                }
            }
            .onAppear {
                title = expense.title
                amount = String(expense.amount)
                selectedCategory = expense.category
                date = expense.date
                notes = expense.notes
            }
        }
    }
    
    func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        expense.title = title
        expense.amount = amountValue
        expense.category = selectedCategory
        expense.date = date
        expense.notes = notes
        
        dismiss()
    }
}

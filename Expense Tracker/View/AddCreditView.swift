//
//  AddCreditView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//
import SwiftUI
import SwiftData
import Charts

struct AddCreditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let viewModel: ExpenseViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedSource = "Salary"
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Credit Details") {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Source") {
                    Picker("Source", selection: $selectedSource) {
                        ForEach(viewModel.creditSources, id: \.name) { source in
                            Label(source.name, systemImage: source.icon)
                                .tag(source.name)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Credit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCredit()
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    func saveCredit() {
        guard let amountValue = Double(amount) else { return }
        
        let credit = Credit(
            title: title,
            amount: amountValue,
            source: selectedSource,
            date: date,
            notes: notes
        )
        
        modelContext.insert(credit)
        dismiss()
    }
}


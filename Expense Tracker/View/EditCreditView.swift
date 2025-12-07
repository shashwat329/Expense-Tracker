//
//  EditCreditView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//
import SwiftUI
import SwiftData

struct EditCreditView: View {
    @Environment(\.dismiss) private var dismiss
    let credit: Credit
    let viewModel: ExpenseViewModel
    
    @State private var title = ""
    @State private var amount = ""
    @State private var selectedSource = ""
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
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Edit Credit")
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
                }
            }
            .onAppear {
                title = credit.title
                amount = String(credit.amount)
                selectedSource = credit.source
                date = credit.date
                notes = credit.notes
            }
        }
    }
    
    func saveCredit() {
        guard let amountValue = Double(amount) else { return }
        
        credit.title = title
        credit.amount = amountValue
        credit.source = selectedSource
        credit.date = date
        credit.notes = notes
        
        dismiss()
    }
}


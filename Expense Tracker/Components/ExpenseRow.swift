//
//  ExpenseRow.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//
import SwiftUI
import Charts
import SwiftData

struct ExpenseRow: View {
    let expense: Expense
    let viewModel: ExpenseViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showingEdit = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: viewModel.categoryIcon(for: expense.category))
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(viewModel.categoryColor(for: expense.category))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)
                
                HStack {
                    Text(expense.category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(expense.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text("₹\(expense.amount,  default: "%.2f")")
                .font(.headline)
                .foregroundStyle(viewModel.categoryColor(for: expense.category))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .contextMenu {
            Button {
                showingEdit = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                modelContext.delete(expense)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditExpenseView(expense: expense, viewModel: viewModel)
        }
    }
}

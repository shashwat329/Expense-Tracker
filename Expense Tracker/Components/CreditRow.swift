//
//  CreditRow.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//
import SwiftUI
import Charts
import SwiftData

struct CreditRow: View {
    let credit: Credit
    let viewModel: ExpenseViewModel
    @Environment(\.modelContext) private var modelContext
    @State private var showingEdit = false
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: viewModel.creditSourceIcon(for: credit.source))
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(viewModel.creditSourceColor(for: credit.source))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(credit.title)
                    .font(.headline)
                
                HStack {
                    Text(credit.source)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text(credit.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text("+₹\(credit.amount,  default: "%.2f")")
                .font(.headline)
                .foregroundStyle(.green)
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
                modelContext.delete(credit)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditCreditView(credit: credit, viewModel: viewModel)
        }
    }
}


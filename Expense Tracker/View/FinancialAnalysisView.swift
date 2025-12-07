//
//  FinancialAnalysisView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//

import SwiftUI
import Charts

struct FinancialAnalysisView: View {
    @Bindable var viewModel: ExpenseViewModel
    
    var monthlyData: [(month: String, credit: Double, expense: Double, net: Double)] {
        let calendar = Calendar.current
        
        // Group credits by month
        let creditGrouped = Dictionary(grouping: viewModel.credits) { credit in
            calendar.dateInterval(of: .month, for: credit.date)?.start ?? credit.date
        }
        
        // Group expenses by month
        let expenseGrouped = Dictionary(grouping: viewModel.expenses) { expense in
            calendar.dateInterval(of: .month, for: expense.date)?.start ?? expense.date
        }
        
        // Combine all months
        var allMonths = Set(creditGrouped.keys)
        allMonths.formUnion(expenseGrouped.keys)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        return allMonths.map { monthStart in
            let credit = creditGrouped[monthStart]?.reduce(0) { $0 + $1.amount } ?? 0
            let expense = expenseGrouped[monthStart]?.reduce(0) { $0 + $1.amount } ?? 0
            return (
                month: formatter.string(from: monthStart),
                credit: credit,
                expense: expense,
                net: credit - expense
            )
        }.sorted { month1, month2 in
            let date1 = formatter.date(from: month1.month) ?? Date()
            let date2 = formatter.date(from: month2.month) ?? Date()
            return date1 < date2
        }
    }
    
    var creditSourceTotals: [(String, Double)] {
        Dictionary(grouping: viewModel.credits, by: { $0.source })
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }
    
    var expenseCategoryTotals: [(String, Double)] {
        Dictionary(grouping: viewModel.expenses, by: { $0.category })
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }
    
    var dailyTrendData: [(date: Date, credit: Double, expense: Double)] {
        let calendar = Calendar.current
        let last30Days = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let creditGrouped = Dictionary(grouping: viewModel.credits.filter { $0.date >= last30Days }) { credit in
            calendar.startOfDay(for: credit.date)
        }
        
        let expenseGrouped = Dictionary(grouping: viewModel.expenses.filter { $0.date >= last30Days }) { expense in
            calendar.startOfDay(for: expense.date)
        }
        
        var allDates = Set(creditGrouped.keys)
        allDates.formUnion(expenseGrouped.keys)
        
        return allDates.map { date in
            let credit = creditGrouped[date]?.reduce(0) { $0 + $1.amount } ?? 0
            let expense = expenseGrouped[date]?.reduce(0) { $0 + $1.amount } ?? 0
            return (date: date, credit: credit, expense: expense)
        }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Overall Net Balance
                    VStack(spacing: 15) {
                        Text("Overall Net Balance")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 15) {
                            StatCard(
                                title: "Total Credit",
                                value: "₹\(viewModel.totalCredit, default: "%.2f")",
                                color: .green
                            )
                            
                            StatCard(
                                title: "Total Expenses",
                                value: "₹\(viewModel.totalExpenses, default: "%.2f")",
                                color: .red
                            )
                        }
                        
                        VStack(spacing: 10) {
                            Text("Net Balance")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("₹\(viewModel.netBalance, default: "%.2f")")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(viewModel.netBalance >= 0 ? .green : .red)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(viewModel.netBalance >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                        )
                    }
                    .padding()
                    
                    // Spending Rate Summary
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Spending Rate Analysis")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            StatCard(
                                title: "Daily Rate",
                                value: "₹\(viewModel.dailySpendingRate, default: "%.2f")",
                                color: viewModel.dailySpendingRate > (viewModel.monthCredit / 30) ? .red : .blue
                            )
                            
                            if viewModel.burnRate > 0 {
                                StatCard(
                                    title: "Days Left",
                                    value: "\(Int(viewModel.burnRate))",
                                    color: viewModel.burnRate < 30 ? .red : viewModel.burnRate < 60 ? .orange : .green
                                )
                            }
                            
                            StatCard(
                                title: "Savings Rate",
                                value: "\(viewModel.savingsRate, default: "%.1f")%",
                                color: viewModel.savingsRate > 20 ? .green : viewModel.savingsRate > 0 ? .orange : .red
                            )
                        }
                        .padding(.horizontal)
                        
                        if viewModel.burnRate > 0 && viewModel.burnRate < 60 {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                Text("Warning: At current spending rate, balance will reach zero in \(Int(viewModel.burnRate)) days")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    
                    // Credit vs Expense Trend (Last 30 Days)
                    if !dailyTrendData.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Credit vs Expenses (Last 30 Days)")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart(dailyTrendData, id: \.date) { data in
                                LineMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Credit", data.credit)
                                )
                                .foregroundStyle(.green)
                                .interpolationMethod(.catmullRom)
                                
                                LineMark(
                                    x: .value("Date", data.date, unit: .day),
                                    y: .value("Expenses", data.expense)
                                )
                                .foregroundStyle(.red)
                                .interpolationMethod(.catmullRom)
                            }
                            .frame(height: 200)
                            .padding()
                            
                            HStack {
                                HStack {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 12, height: 12)
                                    Text("Credit")
                                        .font(.caption)
                                }
                                
                                HStack {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 12, height: 12)
                                    Text("Expenses")
                                        .font(.caption)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Monthly Breakdown
                    if !monthlyData.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Monthly Breakdown")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(monthlyData, id: \.month) { data in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(data.month)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text("₹\(data.net, default: "%.2f")")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundStyle(data.net >= 0 ? .green : .red)
                                    }
                                    
                                    HStack(spacing: 15) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Credit")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text("₹\(data.credit,  default: "%.2f")")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.green)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Expenses")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Text("₹\(data.expense, default: "%.2f")")
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.red)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Credit Sources Breakdown
                    if !creditSourceTotals.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Credit by Source")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart(creditSourceTotals, id: \.0) { source, amount in
                                SectorMark(
                                    angle: .value("Amount", amount),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(viewModel.creditSourceColor(for: source))
                                .annotation(position: .overlay) {
                                    Text("₹\(amount,  default: "%.0f")")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(height: 250)
                            .padding()
                            
                            // Legend
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(creditSourceTotals, id: \.0) { source, amount in
                                    HStack {
                                        Circle()
                                            .fill(viewModel.creditSourceColor(for: source))
                                            .frame(width: 12, height: 12)
                                        Text(source)
                                            .font(.caption)
                                        Spacer()
                                        Text("₹\(amount,  default: "%.0f")")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Expense Categories Breakdown
                    if !expenseCategoryTotals.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Expenses by Category")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            Chart(expenseCategoryTotals, id: \.0) { category, amount in
                                SectorMark(
                                    angle: .value("Amount", amount),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 1.5
                                )
                                .foregroundStyle(viewModel.categoryColor(for: category))
                                .annotation(position: .overlay) {
                                    Text("₹\(amount,  default: "%.0f")")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(height: 250)
                            .padding()
                            
                            // Legend
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(expenseCategoryTotals, id: \.0) { category, amount in
                                    HStack {
                                        Circle()
                                            .fill(viewModel.categoryColor(for: category))
                                            .frame(width: 12, height: 12)
                                        Text(category)
                                            .font(.caption)
                                        Spacer()
                                        Text("₹\(amount,  default: "%.0f")")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Financial Analysis")
        }
    }
}


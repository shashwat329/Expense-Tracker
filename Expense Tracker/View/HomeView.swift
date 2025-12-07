//
//  HomeView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//

import SwiftUI
import SwiftData
import Charts

enum TransactionItem: Identifiable {
    case credit(Credit)
    case expense(Expense)
    
    var id: UUID {
        switch self {
        case .credit(let credit): return credit.id
        case .expense(let expense): return expense.id
        }
    }
    
    var date: Date {
        switch self {
        case .credit(let credit): return credit.date
        case .expense(let expense): return expense.date
        }
    }
    
    var amount: Double {
        switch self {
        case .credit(let credit): return credit.amount
        case .expense(let expense): return expense.amount
        }
    }
}
struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline.bold())
            }
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(colors: [color, color.opacity(0.8)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .cornerRadius(12)
            .shadow(color: color.opacity(0.3), radius: 6, y: 3)
        }
    }
}


struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: ExpenseViewModel
    @State private var showingAddExpense = false
    @State private var showingAddCredit = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Net Balance Card with Action Buttons
                    balanceCard
                    
                    // Quick Stats Grid
                    quickStatsGrid
                    
                    // Spending Insights (if available)
                    if viewModel.dailySpendingRate > 0 {
                        spendingInsights
                    }
                    
                    // Recent Transactions
                    recentTransactionsSection
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Expense Tracker")
            .searchable(text: $viewModel.searchText, prompt: "Search transactions...")
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        exportToCSV()
                    } label: {
                        Label("Export CSV", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAddCredit) {
                AddCreditView(viewModel: viewModel)
            }
        }
    }
    
    // MARK: - Balance Card
    private var balanceCard: some View {
        VStack(spacing: 20) {
            
            // Balance Display
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

                HStack(spacing: 4) {
                    Image(systemName: viewModel.monthNetBalance >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    Text("This Month")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            // NEW: Income & Expense Buttons Here
            HStack(spacing: 16) {
                ActionButton(title: "Income",
                             icon: "plus.circle.fill",
                             color: .green) {
                    showingAddCredit = true
                }

                ActionButton(title: "Expense",
                             icon: "minus.circle.fill",
                             color: .red) {
                    showingAddExpense = true
                }
            }
            .padding(.top, 4)

        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    viewModel.monthNetBalance >= 0 ?
                    Color.green.opacity(0.08) :
                    Color.red.opacity(0.08)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    viewModel.monthNetBalance >= 0 ?
                    Color.green.opacity(0.2) :
                    Color.red.opacity(0.2),
                    lineWidth: 1
                )
        )
        .padding(.horizontal)
    }

    
    // MARK: - Quick Stats Grid
    private var quickStatsGrid: some View {
        VStack(spacing: 16) {
            // Expenses Row
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.purple)
                    Text("Expenses")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack(spacing: 12) {
                    EnhancedSummaryCard(
                        title: "Today",
                        amount: viewModel.todayTotal,
                        icon: "calendar",
                        color: .blue
                    )
                    
                    EnhancedSummaryCard(
                        title: "Week",
                        amount: viewModel.weekTotal,
                        icon: "calendar.badge.clock",
                        color: .green
                    )
                    
                    EnhancedSummaryCard(
                        title: "Month",
                        amount: viewModel.monthTotal,
                        icon: "calendar.circle",
                        color: .purple
                    )
                }
                .padding(.horizontal)
            }
            
            // Credit Display
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "banknote.fill")
                        .foregroundColor(.green)
                    Text("Credit")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
                
                EnhancedStatCard(
                    title: "Total Credit",
                    value: "₹\(viewModel.totalCredit, default: "%.2f")",
                    icon: "arrow.down.circle.fill",
                    color: .green
                )
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Spending Insights
    private var spendingInsights: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.orange)
                Text("Spending Insights")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 12) {
                EnhancedStatCard(
                    title: "Daily Average",
                    value: "₹\(viewModel.dailySpendingRate, default: "%.2f")",
                    icon: "calendar.day.timeline.left",
                    color: viewModel.dailySpendingRate > viewModel.monthCredit / 30 ? .red : .orange
                )
                
                if viewModel.burnRate > 0 {
                    HStack(spacing: 12) {
                        EnhancedStatCard(
                            title: "Days Left",
                            value: "\(Int(viewModel.burnRate))",
                            icon: "hourglass",
                            color: viewModel.burnRate < 30 ? .red : .green,
                            compact: true
                        )
                        
                        EnhancedStatCard(
                            title: "Savings Rate",
                            value: "\(viewModel.savingsRate, default: "%.1f")%",
                            icon: "chart.pie.fill",
                            color: viewModel.savingsRate > 20 ? .green : viewModel.savingsRate > 0 ? .orange : .red,
                            compact: true
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Recent Transactions
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundColor(.blue)
                Text("Recent Transactions")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    Button {
                        viewModel.sortOption = .date
                    } label: {
                        Label("Sort by Date", systemImage: "calendar")
                    }
                    
                    Button {
                        viewModel.sortOption = .amount
                    } label: {
                        Label("Sort by Amount", systemImage: "dollarsign.circle")
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(viewModel.sortOption == .date ? "Date" : "Amount")
                            .font(.caption)
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                    }
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            if viewModel.filteredExpenses.isEmpty && viewModel.filteredCredits.isEmpty {
                EmptyStateView()
            } else {
                let transactionItems: [TransactionItem] = {
                    var items: [TransactionItem] = []
                    for credit in viewModel.filteredCredits {
                        items.append(.credit(credit))
                    }
                    for expense in viewModel.filteredExpenses {
                        items.append(.expense(expense))
                    }
                    
                    switch viewModel.sortOption {
                    case .date:
                        return items.sorted { $0.date > $1.date }
                    case .amount:
                        return items.sorted { $0.amount > $1.amount }
                    }
                }()
                
                VStack(spacing: 8) {
                    ForEach(Array(transactionItems.prefix(10)), id: \.id) { item in
                        switch item {
                        case .credit(let credit):
                            CreditRow(credit: credit, viewModel: viewModel)
                                .padding(.horizontal)
                        case .expense(let expense):
                            ExpenseRow(expense: expense, viewModel: viewModel)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
    
    func exportToCSV() {
        let csv = viewModel.exportCSV()
        let av = UIActivityViewController(activityItems: [csv], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true)
        }
    }
}

// MARK: - Enhanced Summary Card
struct EnhancedSummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("₹\(amount, specifier: "%.0f")")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Enhanced Stat Card
struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var compact: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.system(size: compact ? 18 : 22, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}



//#Preview {
//    HomeView(modelContext: <#T##arg#>, viewModel: <#T##ExpenseViewModel#>, showingAddExpense: <#T##arg#>, showingAddCredit: <#T##arg#>)
//}

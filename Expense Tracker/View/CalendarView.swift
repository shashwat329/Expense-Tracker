//
//  CalendarView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//

import SwiftUI
import SwiftData
import Charts

struct CalendarView: View {
    @Bindable var viewModel: ExpenseViewModel
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Month Selector
                HStack {
                    Button {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                    }
                    
                    Spacer()
                    
                    Text(currentMonth, format: .dateTime.month(.wide).year())
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                    }
                }
                .padding()
                
                // Calendar Grid
                CalendarGridView(viewModel: viewModel, currentMonth: currentMonth, selectedDate: $selectedDate)
                
                Divider()
                
                // Transactions for Selected Date
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text(selectedDate, style: .date)
                                .font(.headline)
                            Spacer()
                            Text("₹\(viewModel.totalAmount(for: selectedDate), specifier: "%.2f")")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                        }
                        .padding()
                        
                        let dayExpenses = viewModel.expenses(for: selectedDate)
                        if dayExpenses.isEmpty {
                            Text("No expenses for this day")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(dayExpenses) { expense in
                                ExpenseRow(expense: expense, viewModel: viewModel)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Calendar")
        }
    }
}
struct CalendarGridView: View {
    let viewModel: ExpenseViewModel
    let currentMonth: Date
    @Binding var selectedDate: Date
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 10) {
            // Weekday headers
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Calendar days
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(generateDates(), id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isCurrentMonth: Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        amount: viewModel.totalAmount(for: date)
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    func generateDates() -> [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        
        var dates: [Date] = []
        
        // Previous month days
        for i in (1..<firstWeekday).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        // Current month days
        let range = calendar.range(of: .day, in: .month, for: currentMonth)!
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        // Next month days to fill grid
        let remaining = 42 - dates.count
        if let lastDate = dates.last {
            for i in 1...remaining {
                if let date = calendar.date(byAdding: .day, value: i, to: lastDate) {
                    dates.append(date)
                }
            }
        }
        
        return dates
    }
}

// MARK: - Calendar Day View

struct CalendarDayView: View {
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let amount: Double
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundStyle(isCurrentMonth ? .primary : .secondary)
            
            if amount > 0 {
                Text("₹\(amount, specifier: "%.0f")")
                    .font(.system(size: 9))
                    .foregroundStyle(.blue)
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .opacity(isCurrentMonth ? 1 : 0.3)
    }
}

// MARK: - Analytics View

//struct AnalyticsView: View {
//    @Bindable var viewModel: ExpenseViewModel
//    
//    var monthlyExpenses: [Expense] {
//        let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
//        return viewModel.expenses.filter { $0.date >= startOfMonth }
//    }
//    
//    var monthlyCredits: [Credit] {
//        let startOfMonth = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
//        return viewModel.credits.filter { $0.date >= startOfMonth }
//    }
//    
//    var categoryTotals: [(String, Double)] {
//        Dictionary(grouping: monthlyExpenses, by: { $0.category })
//            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
//            .sorted { $0.1 > $1.1 }
//    }
//    
//    var creditSourceTotals: [(String, Double)] {
//        Dictionary(grouping: monthlyCredits, by: { $0.source })
//            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
//            .sorted { $0.1 > $1.1 }
//    }
//    
//    var dailyTotals: [(date: Date, credit: Double, expense: Double)] {
//        let calendar = Calendar.current
//        _ = Calendar.current.dateInterval(of: .month, for: Date())?.start ?? Date()
//        
//        let expenseGrouped = Dictionary(grouping: monthlyExpenses) { expense in
//            calendar.startOfDay(for: expense.date)
//        }
//        
//        let creditGrouped = Dictionary(grouping: monthlyCredits) { credit in
//            calendar.startOfDay(for: credit.date)
//        }
//        
//        var allDates = Set(expenseGrouped.keys)
//        allDates.formUnion(creditGrouped.keys)
//        
//        return allDates.map { date in
//            let expense = expenseGrouped[date]?.reduce(0) { $0 + $1.amount } ?? 0
//            let credit = creditGrouped[date]?.reduce(0) { $0 + $1.amount } ?? 0
//            return (date: date, credit: credit, expense: expense)
//        }.sorted { $0.date < $1.date }
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(spacing: 25) {
//                    // Monthly Summary
//                    VStack(spacing: 15) {
//                        Text("This Month")
//                            .font(.headline)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                        
//                        // Net Balance Card
//                        VStack(spacing: 10) {
//                            Text("Net Balance")
//                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
//                            Text("₹\(viewModel.monthNetBalance, specifier: "%.2f")")
//                                .font(.system(size: 28, weight: .bold))
//                                .foregroundStyle(viewModel.monthNetBalance >= 0 ? .green : .red)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(
//                            RoundedRectangle(cornerRadius: 15)
//                                .fill(viewModel.monthNetBalance >= 0 ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
//                        )
//                        
//                        HStack(spacing: 15) {
//                            StatCard(
//                                title: "Total Credit",
//                                value: "₹\(viewModel.monthCredit, default: "%.2f")",
//                                color: .green
//                            )
//                            
//                            StatCard(
//                                title: "Total Spent",
//                                value: "₹\(viewModel.monthTotal, default: "%.2f")",
//                                color: .red
//                            )
//                        }
//                        
//                        HStack(spacing: 15) {
//                            StatCard(
//                                title: "Credit Transactions",
//                                value: "\(monthlyCredits.count)",
//                                color: .green
//                            )
//                            
//                            StatCard(
//                                title: "Expense Transactions",
//                                value: "\(monthlyExpenses.count)",
//                                color: .blue
//                            )
//                        }
//                        
//                        HStack(spacing: 15) {
//                            StatCard(
//                                title: "Avg. Daily Expense",
//                                value: "₹" + String(
//                                    format: "%.2f",
//                                    viewModel.monthTotal / Double(Calendar.current.component(.day, from: Date()))
//                                ),
//                                color: .orange
//                            )
//                            
//                            if let topCategory = categoryTotals.first {
//                                StatCard(
//                                    title: "Top Category",
//                                    value: topCategory.0,
//                                    color: .purple
//                                )
//                            }
//                        }
//                    }
//                    .padding()
//                    
//                    // Category Pie Chart
//                    if !categoryTotals.isEmpty {
//                        VStack(alignment: .leading, spacing: 15) {
//                            Text("Spending by Category")
//                                .font(.headline)
//                                .padding(.horizontal)
//                            
//                            Chart(categoryTotals, id: \.0) { category, amount in
//                                SectorMark(
//                                    angle: .value("Amount", amount),
//                                    innerRadius: .ratio(0.5),
//                                    angularInset: 1.5
//                                )
//                                .foregroundStyle(viewModel.categoryColor(for: category))
//                                .annotation(position: .overlay) {
//                                    Text("₹\(amount, specifier: "%.0f")")
//                                        .font(.caption2)
//                                        .fontWeight(.bold)
//                                        .foregroundStyle(.white)
//                                }
//                            }
//                            .frame(height: 250)
//                            .padding()
//                            
//                            // Legend
//                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
//                                ForEach(categoryTotals, id: \.0) { category, amount in
//                                    HStack {
//                                        Circle()
//                                            .fill(viewModel.categoryColor(for: category))
//                                            .frame(width: 12, height: 12)
//                                        Text(category)
//                                            .font(.caption)
//                                        Spacer()
//                                        Text("₹\(amount, specifier: "%.0f")")
//                                            .font(.caption)
//                                            .fontWeight(.semibold)
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                        .padding(.vertical)
//                        .background(Color(.secondarySystemBackground))
//                        .cornerRadius(15)
//                        .padding(.horizontal)
//                    }
//                    
//                    // Credit Sources Pie Chart
//                    if !creditSourceTotals.isEmpty {
//                        VStack(alignment: .leading, spacing: 15) {
//                            Text("Credit by Source")
//                                .font(.headline)
//                                .padding(.horizontal)
//                            
//                            Chart(creditSourceTotals, id: \.0) { source, amount in
//                                SectorMark(
//                                    angle: .value("Amount", amount),
//                                    innerRadius: .ratio(0.5),
//                                    angularInset: 1.5
//                                )
//                                .foregroundStyle(viewModel.creditSourceColor(for: source))
//                                .annotation(position: .overlay) {
//                                    Text("₹\(amount, specifier: "%.0f")")
//                                        .font(.caption2)
//                                        .fontWeight(.bold)
//                                        .foregroundStyle(.white)
//                                }
//                            }
//                            .frame(height: 250)
//                            .padding()
//                            
//                            // Legend
//                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
//                                ForEach(creditSourceTotals, id: \.0) { source, amount in
//                                    HStack {
//                                        Circle()
//                                            .fill(viewModel.creditSourceColor(for: source))
//                                            .frame(width: 12, height: 12)
//                                        Text(source)
//                                            .font(.caption)
//                                        Spacer()
//                                        Text("₹\(amount, specifier: "%.0f")")
//                                            .font(.caption)
//                                            .fontWeight(.semibold)
//                                    }
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                        .padding(.vertical)
//                        .background(Color(.secondarySystemBackground))
//                        .cornerRadius(15)
//                        .padding(.horizontal)
//                    }
//                    
//                    // Daily Credit vs Expense Chart
//                    if !dailyTotals.isEmpty {
//                        VStack(alignment: .leading, spacing: 15) {
//                            Text("Daily Credit vs Expenses")
//                                .font(.headline)
//                                .padding(.horizontal)
//                            
//                            Chart(dailyTotals, id: \.date) { data in
//                                BarMark(
//                                    x: .value("Date", data.date, unit: .day),
//                                    y: .value("Credit", data.credit)
//                                )
//                                .foregroundStyle(.green.gradient)
//                                .cornerRadius(6)
//                                
//                                BarMark(
//                                    x: .value("Date", data.date, unit: .day),
//                                    y: .value("Expenses", -data.expense)
//                                )
//                                .foregroundStyle(.red.gradient)
//                                .cornerRadius(6)
//                            }
//                            .chartXAxis {
//                                AxisMarks(values: .stride(by: .day)) { value in
//                                    AxisValueLabel(format: .dateTime.month().day())
//                                    AxisGridLine()
//                                    AxisTick()
//                                }
//                            }
//                            .chartYAxis {
//                                AxisMarks(position: .leading) { value in
//                                    AxisValueLabel()
//                                    AxisGridLine()
//                                }
//                            }
//                            .chartPlotStyle { plotArea in
//                                plotArea
////                                    .background(.ultraThinMaterial)
////                                    .cornerRadius(12)
//                            }
//                            .frame(height: 200)
//                            .padding()
//                            
//                            HStack {
//                                HStack {
//                                    Circle()
//                                        .fill(Color.green)
//                                        .frame(width: 12, height: 12)
//                                    Text("Credit")
//                                        .font(.caption)
//                                }
//                                
//                                HStack {
//                                    Circle()
//                                        .fill(Color.red)
//                                        .frame(width: 12, height: 12)
//                                    Text("Expenses")
//                                        .font(.caption)
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                        .padding()
//                        
//                    }
//                }
//                .padding(.vertical)
//            }
//            .navigationTitle("Analytics")
//        }
//    }
//}

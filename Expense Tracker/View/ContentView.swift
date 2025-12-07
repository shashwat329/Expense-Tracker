//
//  ContentView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//

import SwiftUI
import SwiftData
// MARK: - Content View

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var expenses: [Expense]
    @Query private var credits: [Credit]
    @State private var viewModel = ExpenseViewModel()
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            CalendarView(viewModel: viewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            FinancialAnalysisView(viewModel: viewModel)
                .tabItem {
                    Label("Analysis", systemImage: "chart.pie.fill")
                }
            
            SpendingRateView(viewModel: viewModel)
                .tabItem {
                    Label("Spending Rate", systemImage: "speedometer")
                }
            
            CategoriesView(viewModel: viewModel)
                .tabItem {
                    Label("Categories", systemImage: "square.grid.2x2.fill")
                }
            SplitView()
                .tabItem {
                    Label("Split", systemImage: "dollarsign.arrow.circlepath")
                }
            WishlistView(viewModel: viewModel)
                .tabItem {
                    Label("WishList", systemImage: "heart.circle.fill")
                }
                
        }
        .onAppear {
            viewModel.expenses = expenses
            viewModel.credits = credits
        }
        .onChange(of: expenses) {
            viewModel.expenses = expenses
        }
        .onChange(of: credits) {
            viewModel.credits = credits
        }
    }
}


// MARK: - Categories View

struct CategoriesView: View {
    @Bindable var viewModel: ExpenseViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(viewModel.categories) { category in
                        NavigationLink {
                            CategoryDetailView(category: category, viewModel: viewModel)
                        } label: {
                            CategoryCardView(category: category, viewModel: viewModel)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Categories")
        }
    }
}

// MARK: - Category Card

struct CategoryCardView: View {
    let category: Category
    let viewModel: ExpenseViewModel
    
    var categoryExpenses: [Expense] {
        viewModel.expenses(for: category.name)
    }
    
    var totalAmount: Double {
        categoryExpenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: category.icon)
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(category.color.gradient)
                .cornerRadius(20)
            
            VStack(spacing: 5) {
                Text(category.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("₹\(totalAmount,  default: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(category.color)
                
                Text("\(categoryExpenses.count) transactions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

// MARK: - Category Detail View

struct CategoryDetailView: View {
    let category: Category
    let viewModel: ExpenseViewModel
    
    var categoryExpenses: [Expense] {
        viewModel.expenses(for: category.name).sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Category Header
                VStack(spacing: 10) {
                    Image(systemName: category.icon)
                        .font(.system(size: 60))
                        .foregroundStyle(.white)
                        .frame(width: 120, height: 120)
                        .background(category.color.gradient)
                        .cornerRadius(30)
                    
                    Text(category.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("₹\(categoryExpenses.reduce(0) { $0 + $1.amount },  default: "%.2f")")
                        .font(.title2)
                        .foregroundStyle(category.color)
                }
                .padding()
                
                // Transactions List
                VStack(alignment: .leading, spacing: 10) {
                    Text("Transactions (\(categoryExpenses.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if categoryExpenses.isEmpty {
                        Text("No transactions in this category")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(categoryExpenses) { expense in
                            ExpenseRow(expense: expense, viewModel: viewModel)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Empty State View



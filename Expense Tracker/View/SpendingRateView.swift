//
//  SpendingRateView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 06/12/25.
//

import SwiftUI
import Charts

struct SpendingRateView: View {
    @Bindable var viewModel: ExpenseViewModel
    
    var financialHealthScore: Double {
        // Score out of 100 based on multiple factors
        var score: Double = 50
        
        // Savings rate contribution (0-30 points)
        if viewModel.savingsRate > 20 {
            score += 30
        } else if viewModel.savingsRate > 10 {
            score += 20
        } else if viewModel.savingsRate > 0 {
            score += 10
        }
        
        // Burn rate contribution (0-25 points)
        if viewModel.burnRate > 90 {
            score += 25
        } else if viewModel.burnRate > 60 {
            score += 15
        } else if viewModel.burnRate > 30 {
            score += 5
        }
        
        // Spending velocity contribution (0-20 points)
        if viewModel.spendingVelocity < -10 {
            score += 20 // Spending decreasing
        } else if viewModel.spendingVelocity < 0 {
            score += 10
        } else if viewModel.spendingVelocity > 20 {
            score -= 10 // Spending increasing rapidly
        }
        
        // Net balance contribution (0-25 points)
        if viewModel.netBalance > 0 {
            score += min(25, viewModel.netBalance / 1000 * 5)
        } else {
            score -= 15
        }
        
        return max(0, min(100, score))
    }
    
    var healthStatus: (color: Color, text: String) {
        let score = financialHealthScore
        if score >= 75 {
            return (.green, "Excellent")
        } else if score >= 60 {
            return (.green, "Good")
        } else if score >= 45 {
            return (.orange, "Fair")
        } else if score >= 30 {
            return (.orange, "Needs Attention")
        } else {
            return (.red, "Critical")
        }
    }
    
    var projectedData: [(days: Int, balance: Double)] {
        [30, 60, 90].map { days in
            (days: days, balance: viewModel.projectedBalance(days: days))
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Financial Health Score
                    VStack(spacing: 15) {
                        Text("Financial Health Score")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                                .frame(width: 150, height: 150)
                            
                            Circle()
                                .trim(from: 0, to: financialHealthScore / 100)
                                .stroke(healthStatus.color, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                                .frame(width: 150, height: 150)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring, value: financialHealthScore)
                            
                            VStack {
                                Text("\(Int(financialHealthScore))")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(healthStatus.color)
                                Text(healthStatus.text)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    
                    // Spending Rates
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Spending Rates")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            StatCard(
                                title: "Daily Avg",
                                value: "₹\(viewModel.dailySpendingRate, default: "%.2f")",
                                color: viewModel.dailySpendingRate > viewModel.monthCredit / 30 ? .red : .blue
                            )
                            
                            StatCard(
                                title: "Weekly Avg",
                                value: "₹\(viewModel.weeklySpendingRate, default: "%.2f")",
                                color: .orange
                            )
                            
                            StatCard(
                                title: "Monthly Avg",
                                value: "₹\(viewModel.monthlySpendingRate, default: "%.2f")",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    // Burn Rate & Savings Rate
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Financial Sustainability")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.burnRate > 0 {
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Days Until Balance Reaches Zero")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(Int(viewModel.burnRate)) days")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundStyle(viewModel.burnRate < 30 ? .red : viewModel.burnRate < 60 ? .orange : .green)
                                }
                                
                                ProgressView(value: min(1.0, viewModel.burnRate / 90))
                                    .tint(viewModel.burnRate < 30 ? .red : viewModel.burnRate < 60 ? .orange : .green)
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("Savings Rate")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(viewModel.savingsRate, specifier: "%.1f")%")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(viewModel.savingsRate > 20 ? .green : viewModel.savingsRate > 0 ? .orange : .red)
                            }
                            
                            ProgressView(value: max(0, min(1.0, viewModel.savingsRate / 100)))
                                .tint(viewModel.savingsRate > 20 ? .green : viewModel.savingsRate > 0 ? .orange : .red)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Spending Velocity
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Spending Trend")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Velocity")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(viewModel.spendingVelocity > 0 ? "+" : "")\(viewModel.spendingVelocity, specifier: "%.1f")%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(viewModel.spendingVelocity < 0 ? .green : viewModel.spendingVelocity > 20 ? .red : .orange)
                            }
                            
                            Spacer()
                            
                            Image(systemName: viewModel.spendingVelocity < 0 ? "arrow.down.circle.fill" : viewModel.spendingVelocity > 20 ? "arrow.up.circle.fill" : "arrow.right.circle.fill")
                                .font(.title)
                                .foregroundStyle(viewModel.spendingVelocity < 0 ? .green : viewModel.spendingVelocity > 20 ? .red : .orange)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Projected Balance
                    if !projectedData.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Projected Balance")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            //                            Chart(projectedData, id: \.days) { data in
                            //                                BarMark(
                            //                                    x: .value("Days", "\(data.days)d"),
                            //                                    y: .value("Balance", data.balance)
                            //                                )
                            //                                .foregroundStyle(data.balance >= 0 ? .green.gradient : .red.gradient)
                            //                                .annotation(position: .top) {
                            //                                    Text("₹\(data.balance, specifier: "%.0f")")
                            //                                        .font(.caption2)
                            //                                        .foregroundStyle(data.balance >= 0 ? .green : .red)
                            //                                }
                            //                            }
                            //                            .frame(height: 200)
                            //                            .padding()
                            
                            Text("Based on current spending rate")
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
            .navigationTitle("Spending Rate Analysis")
        }
    }
}


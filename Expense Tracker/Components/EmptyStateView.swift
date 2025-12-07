//
//  EmptyStateView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 07/12/25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("No Transactions Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to add your first income or expense")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

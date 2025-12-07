//
//  SplitView.swift
//  Expense Tracker
//
//  Created by shashwat singh on 07/12/25.
//
import SwiftUI
import SwiftData

struct SplitView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var splitRooms: [SplitRoom]
    @State private var showingCreateRoom = false
    
    var body: some View {
        NavigationStack {
            Group {
                if splitRooms.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text("No Split Rooms")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Create a room to split expenses with friends")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            showingCreateRoom = true
                        } label: {
                            Label("Create Room", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding()
                                .background(Color.blue.gradient)
                                .cornerRadius(12)
                        }
                    }
                    .padding(40)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(splitRooms) { room in
                                NavigationLink {
                                    SplitRoomDetailView(room: room)
                                } label: {
                                    SplitRoomCard(room: room)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Split Bills")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateRoom = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCreateRoom) {
                CreateSplitRoomView()
            }
        }
    }
}

// MARK: - Split Room Card

struct SplitRoomCard: View {
    let room: SplitRoom
    
    var totalExpenses: Double {
        room.expenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "person.3.fill")
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(Color.blue.gradient)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(room.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack {
                    Text("\(room.members.count) members")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("•")
                        .foregroundStyle(.secondary)
                    
                    Text("\(room.expenses.count) expenses")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("₹\(totalExpenses, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundStyle(.blue)
                
                Text("Total")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

// MARK: - Create Split Room View

struct CreateSplitRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var roomName = ""
    @State private var members: [RoomMember] = []
    @State private var showingAddMember = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Room Details") {
                    TextField("Room Name", text: $roomName)
                        .textContentType(.name)
                }
                
                Section {
                    Button {
                        showingAddMember = true
                    } label: {
                        Label("Add Member", systemImage: "person.badge.plus")
                    }
                } header: {
                    Text("Members (\(members.count))")
                }
                
                if !members.isEmpty {
                    Section {
                        ForEach(members) { member in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(member.name)
                                        .font(.headline)
                                    
                                    if !member.phoneNumber.isEmpty {
                                        Text(member.phoneNumber)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(role: .destructive) {
                                    if let index = members.firstIndex(where: { $0.id == member.id }) {
                                        members.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createRoom()
                    }
                    .disabled(roomName.isEmpty || members.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddMember) {
                AddMemberView(members: $members)
            }
        }
    }
    
    func createRoom() {
        let room = SplitRoom(name: roomName, members: members)
        modelContext.insert(room)
        dismiss()
    }
}

// MARK: - Add Member View

struct AddMemberView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var members: [RoomMember]
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var showingContacts = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Member Details") {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                    
                    TextField("Phone Number", text: $phoneNumber)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                    TextField("Email (Optional)", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section {
                    Button {
                        // In a real app, this would open contacts picker
                        // For now, we'll show an alert
                        showingContacts = true
                    } label: {
                        Label("Import from Contacts", systemImage: "person.crop.circle.badge.plus")
                    }
                }
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMember()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .alert("Import Contacts", isPresented: $showingContacts) {
                Button("OK") { }
            } message: {
                Text("To enable contact import, add Contacts framework and request permission in Info.plist. This is a demo showing the UI flow.")
            }
        }
    }
    
    func addMember() {
        let member = RoomMember(name: name, phoneNumber: phoneNumber, email: email)
        members.append(member)
        dismiss()
    }
}

// MARK: - Split Room Detail View

struct SplitRoomDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let room: SplitRoom
    @State private var showingAddExpense = false
    @State private var showingSettlement = false
    
    var totalExpenses: Double {
        room.expenses.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary Cards
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Total Spent")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("₹\(totalExpenses, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Per Person")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text("₹\(totalExpenses / Double(max(room.members.count, 1)), specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Members Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Members")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(room.members) { member in
                        MemberBalanceCard(member: member, room: room)
                            .padding(.horizontal)
                    }
                }
                
                // Expenses Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Expenses")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if room.expenses.isEmpty {
                        Text("No expenses yet")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(room.expenses.sorted(by: { $0.date > $1.date })) { expense in
                            SplitExpenseRow(expense: expense)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(room.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Label("Add Expense", systemImage: "plus.circle")
                    }
                    
                    Button {
                        showingSettlement = true
                    } label: {
                        Label("Settle Up", systemImage: "dollarsign.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddSplitExpenseView(room: room)
        }
        .sheet(isPresented: $showingSettlement) {
            SettlementView(room: room)
        }
    }
}

// MARK: - Member Balance Card

struct MemberBalanceCard: View {
    let member: RoomMember
    let room: SplitRoom
    
    var memberExpenses: Double {
        room.expenses.filter { $0.paidBy == member.name }.reduce(0) { $0 + $1.amount }
    }
    
    var memberOwes: Double {
        let totalExpenses = room.expenses.reduce(0) { $0 + $1.amount }
        let perPerson = totalExpenses / Double(max(room.members.count, 1))
        return perPerson - memberExpenses
    }
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(member.name)
                    .font(.headline)
                
                if !member.phoneNumber.isEmpty {
                    Text(member.phoneNumber)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("₹\(memberExpenses, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                if memberOwes > 0 {
                    Text("Owes $\(abs(memberOwes), specifier: "%.2f")")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else if memberOwes < 0 {
                    Text("Gets $\(abs(memberOwes), specifier: "%.2f")")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text("Settled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Split Expense Row

struct SplitExpenseRow: View {
    let expense: SplitExpense
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(expense.title)
                    .font(.headline)
                
                Spacer()
                
                Text("₹\(expense.amount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }
            
            HStack {
                Text("Paid by \(expense.paidBy)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Text(expense.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !expense.splitAmong.isEmpty {
                Text("Split: \(expense.splitAmong.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Add Split Expense View

struct AddSplitExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    let room: SplitRoom
    
    @State private var title = ""
    @State private var amount = ""
    @State private var paidBy = ""
    @State private var selectedMembers: Set<String> = []
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section("Paid By") {
                    Picker("Who paid?", selection: $paidBy) {
                        Text("Select").tag("")
                        ForEach(room.members) { member in
                            Text(member.name).tag(member.name)
                        }
                    }
                }
                
                Section("Split Among") {
                    ForEach(room.members) { member in
                        Toggle(member.name, isOn: Binding(
                            get: { selectedMembers.contains(member.name) },
                            set: { isSelected in
                                if isSelected {
                                    selectedMembers.insert(member.name)
                                } else {
                                    selectedMembers.remove(member.name)
                                }
                            }
                        ))
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addExpense()
                    }
                    .disabled(title.isEmpty || amount.isEmpty || paidBy.isEmpty || selectedMembers.isEmpty)
                }
            }
            .onAppear {
                // Pre-select all members
                selectedMembers = Set(room.members.map { $0.name })
            }
        }
    }
    
    func addExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let expense = SplitExpense(
            title: title,
            amount: amountValue,
            paidBy: paidBy,
            splitAmong: Array(selectedMembers),
            date: date,
            notes: notes
        )
        
        room.expenses.append(expense)
        dismiss()
    }
}

// MARK: - Settlement View

struct SettlementView: View {
    @Environment(\.dismiss) private var dismiss
    let room: SplitRoom
    
    var settlements: [(from: String, to: String, amount: Double)] {
        var balances: [String: Double] = [:]
        
        // Calculate balances
        let totalExpenses = room.expenses.reduce(0) { $0 + $1.amount }
        let perPerson = totalExpenses / Double(max(room.members.count, 1))
        
        for member in room.members {
            let paid = room.expenses.filter { $0.paidBy == member.name }.reduce(0) { $0 + $1.amount }
            balances[member.name] = paid - perPerson
        }
        
        // Calculate settlements
        var settlements: [(String, String, Double)] = []
        var debtors = balances.filter { $0.value < 0 }.sorted { $0.value < $1.value }
        var creditors = balances.filter { $0.value > 0 }.sorted { $0.value > $1.value }
        
        var debtorIndex = 0
        var creditorIndex = 0
        
        while debtorIndex < debtors.count && creditorIndex < creditors.count {
            let debtor = debtors[debtorIndex]
            let creditor = creditors[creditorIndex]
            
            let settleAmount = min(abs(debtor.value), creditor.value)
            settlements.append((debtor.key, creditor.key, settleAmount))
            
            debtors[debtorIndex].value += settleAmount
            creditors[creditorIndex].value -= settleAmount
            
            if abs(debtors[debtorIndex].value) < 0.01 {
                debtorIndex += 1
            }
            if creditors[creditorIndex].value < 0.01 {
                creditorIndex += 1
            }
        }
        
        return settlements
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if settlements.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(.green)
                            
                            Text("All Settled!")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Everyone is even")
                                .foregroundStyle(.secondary)
                        }
                        .padding(40)
                    } else {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Suggested Settlements")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(settlements, id: \.from) { settlement in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(settlement.from)
                                            .font(.headline)
                                        Text("pays")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .foregroundStyle(.blue)
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text(settlement.to)
                                            .font(.headline)
                                        Text("₹\(settlement.amount, specifier: "%.2f")")
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.green)
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Settlement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

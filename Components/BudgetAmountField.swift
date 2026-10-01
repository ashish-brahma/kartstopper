//
//  BudgetAmountField.swift
//  KartStopper
//
//  Created by Ashish Brahma on 20/09/26.
//
//  A SwiftUI text field view that edits the monthly
//  budget amount in preferences.

import SwiftUI
import CoreData
internal import Combine

struct BudgetAmountField: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var preferencesModel: PreferencesModel
    
    @Environment(\.locale) private var locale
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @FocusState private var isFocused: Bool
    
    var currencyCode: String {
        locale.currency?.identifier ?? "USD"
    }
    
    var isValidAmount: Bool {
        if let savedAmount = preferencesModel.budgetAmount {
            return savedAmount > 0
        }
        return false
    }
    
    var body: some View {
        List {
            Section {
                TextField(
                    "Budget amount in \(currencyCode)",
                    value: $preferencesModel.budgetAmount,
                    format: .currency(code: currencyCode)
                )
                .focused($isFocused)
                .keyboardType(.decimalPad)
                .disabled(viewModel.budget.isLocked)
                .foregroundStyle(viewModel.budget.isLocked ? .secondary : .primary)
            } footer: {
                budgetAmountFooter()
            }
            .listRowBackground(viewModel.budget.isLocked ? Color(.tertiarySystemFill) : Color(.secondarySystemGroupedBackground))
        }
        .navigationTitle("Monthly Budget")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            editorToolbar()
        }
        .onAppear {
            if !viewModel.budget.isLocked {
                isFocused = true
            }
        }
        .task {
            if viewModel.hasOnboarded {
                viewModel.budget.updateBudgetLock()
            }
        }
        .onChange(of: viewModel.hasOnboarded) { boarded in
            if boarded {
                viewModel.objectWillChange.send()
                viewModel.budget.updateBudgetLock()
            }
        }
    }
    
    private func updateAmount() {
        guard let savedAmount = preferencesModel.budgetAmount
        else { return }
        
        let displayAmount = viewModel.budget.budgetAmount
        
        if savedAmount != displayAmount {
            preferencesModel.objectWillChange.send()
            preferencesModel.saveData()
            viewModel.objectWillChange.send()
            viewModel.budget.budgetAmount = savedAmount
            viewModel.update(context: viewContext)
        }
    }
    
    private func updateOnboarding() {
        if !viewModel.hasOnboarded && isValidAmount {
            hasOnboarded = true
            viewModel.updateOnboardingState()
        }
    }
    
    @ViewBuilder
    private func budgetAmountFooter() -> some View {
        if !viewModel.budget.isLocked {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "exclamationmark.circle")
                    .padding(.trailing, -Design.Padding.trailing/4)
                
                Text(Constants.Manage.monthlyBudgetWarning)
            }
            .font(.caption)
            .foregroundStyle(Color.warning)
        }
    }
    
    @ToolbarContentBuilder
    private func editorToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            CancelToolbarButton {
                isFocused = false
            }
            Spacer()
            ConfirmToolbarButton {
                updateAmount()
                updateOnboarding()
                isFocused = false
            }
            .disabled(!isValidAmount)
        }
    }
}

#Preview {
    NavigationStack {
        BudgetAmountField(
            viewModel: .preview,
            preferencesModel: PreferencesModel()
        )
    }
}

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
    
    var body: some View {
        Section {
            HStack {
                TextField(
                    "Budget amount in \(currencyCode)",
                    value: $preferencesModel.budgetAmount,
                    format: .currency(code: currencyCode)
                )
                .focused($isFocused)
                .keyboardType(.decimalPad)
                .disabled(viewModel.budget.isLocked)
                
                if viewModel.budget.isLocked {
                    Label("Budget Lock", systemImage: "lock.fill")
                        .labelStyle(.iconOnly)
                }
            }
            .foregroundStyle(viewModel.budget.isLocked ? .secondary : .primary)
            .toolbar {
                editorToolbar()
            }
        } header: {
            Text("Monthly Budget")
        } footer: {
            budgetAmountFooter()
        }
        .listRowBackground(viewModel.budget.isLocked ? Color(.tertiarySystemFill) : Color(.secondarySystemGroupedBackground))
        .task {
            if viewModel.hasOnboarded {
                viewModel.budget.updateBudgetLock()
            } else {
                isFocused = true
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
        guard let amount = viewModel.budget.budgetAmount
        else { return }
        
        if !viewModel.hasOnboarded && amount > 0 {
            hasOnboarded = true
            viewModel.updateOnboardingState()
        }
    }
    
    @ViewBuilder
    private func budgetAmountFooter() -> some View {
        VStack(alignment: .leading) {
            Text(Constants.Manage.monthlyBudgetFooter)
            
            if isFocused {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "exclamationmark.circle")
                        .padding(.trailing, -Design.Padding.trailing/4)
                    
                    Text(Constants.Manage.monthlyBudgetWarning)
                }
                .padding(.vertical, -Design.Padding.vertical)
                .font(.caption)
                .foregroundStyle(Color.warning)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func editorToolbar() -> some ToolbarContent {
        if isFocused {
            ToolbarItem(placement: .confirmationAction) {
                ConfirmToolbarButton {
                    updateAmount()
                    updateOnboarding()
                    isFocused = false
                }
            }
            ToolbarItem(placement: .cancellationAction) {
                CancelToolbarButton {
                    isFocused = false
                }
            }
        }
    }
}

#Preview {
    List {
        BudgetAmountField(
            viewModel: .preview,
            preferencesModel: PreferencesModel()
        )
    }
}

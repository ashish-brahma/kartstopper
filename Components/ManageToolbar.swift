//
//  ManageToolbar.swift
//  KartStopper
//
//  Created by Ashish Brahma on 20/09/26.
//
//  A SwiftUI view that configures toolbar content of
//  preferences' navigation stack.

import SwiftUI

struct ManageToolbar: ToolbarContent {
    @ObservedObject var viewModel: ViewModel
    
    @Binding var isEditing: Bool
    @Binding var budgetAmount: Double
    @Binding var hasOnboarded: Bool
    @Binding var difficulty: BudgetMode
    
    private var message: String {
        if !viewModel.hasOnboarded {
            if budgetAmount == 0.00 {
                return "Enter budget amount"
            } else if budgetAmount > 0 {
                return "Unsaved changes"
            }
        } else if isEditing {
            if budgetAmount != viewModel.budget.budgetAmount
                || difficulty != viewModel.budget.budgetMode {
                return "Unsaved changes"
            }
        }
        return ""
    }
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button {
                if !viewModel.hasOnboarded && budgetAmount > 0 {
                    hasOnboarded = true
                    viewModel.updateOnboardingState()
                }
                
                UserDefaults.standard.set(difficulty.rawValue, forKey: "budgetMode")
                viewModel.budget.updateBudgetSettings()
                
                isEditing = false
            } label: {
                Label("Save", systemImage: "checkmark")
            }
            .disabled(!isEditing || budgetAmount == 0.00)
        }
        if isEditing {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    budgetAmount = viewModel.hasOnboarded ? viewModel.budget.budgetAmount : 0.00
                    difficulty = viewModel.hasOnboarded ? viewModel.budget.budgetMode : .medium
                    isEditing = false
                } label: {
                    Label("Cancel", systemImage: "xmark")
                }
            }
        }
        ToolbarItem(placement: .principal) {
            Text(message)
                .font(.caption.bold())
                .foregroundStyle(.accent)
        }
    }
}

#Preview {
    let viewModel = ViewModel.preview
    NavigationStack {
        List {
            TextField("Budget Amount", text: .constant(""))
        }
        .navigationTitle("Preferences")
        .toolbar {
            ManageToolbar(
                viewModel: viewModel,
                isEditing: .constant(true),
                budgetAmount: .constant(viewModel.budget.budgetAmount),
                hasOnboarded: .constant(viewModel.hasOnboarded),
                difficulty: .constant(viewModel.budget.budgetMode)
            )
        }
    }
}

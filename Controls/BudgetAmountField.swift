//
//  BudgetAmountField.swift
//  KartStopper
//
//  Created by Ashish Brahma on 20/09/26.
//
//  A SwiftUI text field view that edits the monthly
//  budget amount in preferences.

import SwiftUI
internal import Combine

struct BudgetAmountField: View {
    @ObservedObject var viewModel: ViewModel
    
    @Environment(\.locale) private var locale
    
    @Binding var budgetAmount: Double
    
    var body: some View {
        HStack {
            TextField("Budget",
                      value: $budgetAmount,
                      format: .currency(code: locale.currency?.identifier ?? "USD"))
            .keyboardType(.numbersAndPunctuation)
            .submitLabel(.done)
            .disabled(viewModel.budget.isLocked)
            
            if viewModel.budget.isLocked {
                Label("Budget Lock", systemImage: "lock.fill")
                    .labelStyle(.iconOnly)
            }
        }
        .foregroundStyle(viewModel.budget.isLocked ? .secondary : .primary)
    }
}

#Preview {
    let viewModel = ViewModel.preview
    List {
        BudgetAmountField(viewModel: viewModel,
                          budgetAmount: .constant(viewModel.budget.budgetAmount))
    }
}

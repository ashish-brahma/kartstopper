//
//  BudgetAmountNavigationButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 04/10/26.
//
//  A SwiftUI button view that presents budget amount editor view.

import SwiftUI

struct BudgetAmountNavigationButton: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var preferencesModel: PreferencesModel
    
    @Binding var showEditor: Bool
    @Binding var field: ManageField?
    
    @Environment(\.locale) private var locale
    
    var currencyCode: String {
        locale.currency?.identifier ?? "USD"
    }
    
    var body: some View {
        Button {
            field = .budgetAmount
            showEditor = true
        } label: {
            NavigationLink(value: ManageField.budgetAmount) {
                LabeledContent {
                    if let amount = viewModel.budget.budgetAmount {
                        Text(amount.formatted(.currency(code: currencyCode)))
                    } else {
                        Text("Enter an amount")
                    }
                } label: {
                    Label("Amount", systemImage: "number.square")
                }
            }
        }
        .tint(.primary)
    }
}

#Preview {
    NavigationStack {
        Form {
            BudgetAmountNavigationButton(
                viewModel: .preview,
                preferencesModel: PreferencesModel(),
                showEditor: .constant(false),
                field: .constant(.budgetAmount)
            )
        }
    }
}

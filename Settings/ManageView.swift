//
//  ManageView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/12/25.
//
//  A SwiftUI view that shows user preferences.

import SwiftUI
internal import Combine

struct ManageView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var navModel: NavigationModel
    
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("budgetAmount") private var budgetAmount: Double = 0.00
    @State private var difficulty: BudgetMode = .medium
    @State private var isEditing: Bool = false
    
    @FocusState private var focusedField: ManageField?
    
    var body: some View {
        NavigationStack(path: $navModel.presentedCredits) {
            Form {
                Section {
                    BudgetAmountField(viewModel: viewModel,
                                      budgetAmount: $budgetAmount)
                        .focused($focusedField, equals: .budgetAmount)
                        .onSubmit {
                            focusedField = nil
                        }
                } header: {
                    Text("Monthly Budget")
                } footer: {
                    Text(Constants.Manage.monthlyBudgetFooter)
                }
                .listRowBackground(viewModel.budget.isLocked ? Color(.tertiarySystemFill) : Color(.secondarySystemGroupedBackground))
                
                Section {
                    BudgetModePicker(difficulty: $difficulty)
                } header: {
                    Text("Budget Mode")
                } footer: {
                    Text(Constants.Manage.budgetModeFooter)
                }
                
                Section {
                    LinkButton(urlString: Constants.Manage.faqURL,
                               title: "Frequently Asked Questions")
                    
                    LinkButton(urlString: Constants.Manage.privacyURL,
                               title: "Privacy Policy")
                    
                    LinkButton(urlString: Constants.Manage.contactURL,
                               title: "Write to us")
                } header: {
                    Text("Help & Support")
                }
                
                Section {
                    NavigationLink("Legal", value: Credits.legal)
                    
                    NavigationLink("Developer", value: Credits.developer)
                    
                    LinkButton(urlString: Constants.Manage.repositoryURL,
                               title: "Github Repository")
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Preferences")
            .navigationTitleColor(Color.foreground)
            .navigationDestination(for: Credits.self) { document in
                switch document {
                case .legal:
                    LegalView()
                case .developer:
                    DeveloperView()
                }
            }
            .task {
                if viewModel.hasOnboarded {
                    viewModel.budget.updateBudgetLock()
                } else {
                    isEditing = true
                    focusedField = .budgetAmount
                }
                if let mode = viewModel.budget.selectedModes.first {
                    difficulty = mode
                }
            }
            .toolbar {
                ManageToolbar(
                    viewModel: viewModel,
                    isEditing: $isEditing,
                    budgetAmount: $budgetAmount,
                    hasOnboarded: $hasOnboarded,
                    difficulty: $difficulty
                )
            }
            .onChange(of: viewModel.hasOnboarded) { newValue in
                if newValue {
                    viewModel.objectWillChange.send()
                    viewModel.budget.updateBudgetLock()
                }
            }
            .onChange(of: budgetAmount) { newValue in
                isEditing = (newValue != viewModel.budget.budgetAmount)
            }
            .onChange(of: difficulty) { newValue in
                isEditing = (newValue != viewModel.budget.budgetMode)
            }
            .onChange(of: isEditing) { newValue in
                if !newValue {
                    focusedField = nil
                }
            }
        }
    }
}

#Preview {
    ManageView(viewModel: .preview,
               navModel: NavigationModel())
}

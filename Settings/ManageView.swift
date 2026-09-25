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
    
    @StateObject var preferencesModel = PreferencesModel()
    
    @FocusState private var focusedField: ManageField?
    
    var message: String {
        if !viewModel.hasOnboarded
            && viewModel.budget.budgetAmount == nil {
            
            return "Enter an amount"
        
        } else if viewModel.budget.budgetMode == nil {
            
            return "Choose a mode"
        }
        return ""
    }
    
    var body: some View {
        NavigationStack(path: $navModel.presentedCredits) {
            Form {
                Section {
                    BudgetAmountField(
                        viewModel: viewModel,
                        budgetAmount: $preferencesModel.budgetAmount
                    )
                    .focused($focusedField, equals: .budgetAmount)
                    .onSubmit {
                        updateAmount()
                        updateOnboarding()
                        focusedField = nil
                    }
                } header: {
                    Text("Monthly Budget")
                } footer: {
                    Text(Constants.Manage.monthlyBudgetFooter)
                }
                .listRowBackground(viewModel.budget.isLocked ? Color(.tertiarySystemFill) : Color(.secondarySystemGroupedBackground))
                
                Section {
                    BudgetModePicker(difficulty: $preferencesModel.selectedMode)
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
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("\(message)")
                        .foregroundStyle(Color.foreground)
                }
            }
            .task {
                if viewModel.hasOnboarded {
                    viewModel.budget.updateBudgetLock()
                } else {
                    focusedField = .budgetAmount
                }
                
                preferencesModel.loadData()
                preferencesModel.objectWillChange.send()
                initViewModel()
            }
            .onChange(of: preferencesModel.selectedMode) { _ in
                updateMode()
            }
            .onChange(of: viewModel.hasOnboarded) { boarded in
                if boarded {
                    viewModel.objectWillChange.send()
                    viewModel.budget.updateBudgetLock()
                }
            }
        }
    }
    
    private func updateAmount() {
        guard let savedAmount = preferencesModel.budgetAmount
        else { return }
        
        let displayAmount = viewModel.budget.budgetAmount
        
        if savedAmount != displayAmount {
            preferencesModel.saveData()
            preferencesModel.objectWillChange.send()
            viewModel.budget.budgetAmount = savedAmount
        }
    }
    
    private func updateMode() {
        guard let savedMode = preferencesModel.selectedMode
        else { return }
        
        let displayMode = viewModel.budget.budgetMode
        
        if savedMode != displayMode {
            preferencesModel.saveData()
            preferencesModel.objectWillChange.send()
            viewModel.budget.budgetMode = savedMode
        }
    }
    
    private func initViewModel() {
        if let amount = preferencesModel.budgetAmount {
            viewModel.budget.budgetAmount = amount
        }
        
        if let mode = preferencesModel.selectedMode {
            viewModel.budget.budgetMode = mode
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
}

/// Type that manages focus state in preferences.
enum ManageField: Hashable {
    case budgetAmount
}

#Preview {
    ManageView(viewModel: .preview,
               navModel: NavigationModel())
}

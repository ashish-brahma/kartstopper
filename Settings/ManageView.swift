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
    
    @Environment(\.openURL) private var openURL
    @Environment(\.locale) private var locale
    
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @AppStorage("budgetAmount") private var budgetAmount: Double = 0.00
    @State private var difficulty: Mode = .medium
    @State private var isEditing: Bool = false
    @FocusState private var isEditingBudget: Bool
    
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
    
    var body: some View {
        Form {
            Section {
                budgetStepper()
                    .disabled(viewModel.budget.isLocked)
                    .foregroundStyle(viewModel.budget.isLocked ? .secondary : .primary)
            } header: {
                Text("Monthly Budget")
            } footer: {
                Text(Constants.Manage.monthlyBudgetFooter)
            }
            
            Section {
                difficultyPicker()
            } header: {
                Text("Budget Mode")
            } footer: {
                Text(Constants.Manage.budgetModeFooter)
            }
            
            Section {
                linkButton(urlString: Constants.Manage.faqURL,
                           title: "Frequently Asked Questions")
                
                linkButton(urlString: Constants.Manage.privacyURL,
                           title: "Privacy Policy")
                
                linkButton(urlString: Constants.Manage.contactURL,
                           title: "Write to us")
            } header: {
                Text("Help & Support")
            }
            
            Section {
                legal()
                developer()
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Preferences")
        .navigationTitleColor(Color.foreground)
        .scrollContentBackground(.hidden)
        .background(Color.background)
        .task {
            if viewModel.hasOnboarded {
                viewModel.budget.updateBudgetLock()
            } else {
                isEditing = true
                isEditingBudget = true
            }
            if let mode = viewModel.budget.selectedModes.first {
                difficulty = mode
            }
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    if !viewModel.hasOnboarded && budgetAmount > 0 {
                        hasOnboarded = true
                        viewModel.updateOnboardingState()
                    }
                    
                    UserDefaults.standard.set(difficulty.rawValue, forKey: "budgetMode")
                    viewModel.budget.updateBudgetSettings()
                    
                    isEditing = false
                    isEditingBudget = false
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
                        isEditingBudget = false
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
    }
    
    @ViewBuilder
    private func budgetStepper() -> some View {
        Stepper {
            budgetField()
        } onIncrement: {
            viewModel.objectWillChange.send()
            budgetAmount += 1
        } onDecrement: {
            viewModel.objectWillChange.send()
            budgetAmount -= 1
            if budgetAmount < 1 {
                budgetAmount = 1
            }
        }
    }
    
    @ViewBuilder
    private func budgetField() -> some View {
        HStack {
            if viewModel.budget.isLocked {
                Label("Budget Lock", systemImage: "lock.fill")
                    .labelStyle(.iconOnly)
            }
            
            TextField("Budget",
                      value: $budgetAmount,
                      format: .currency(code: locale.currency?.identifier ?? "USD"))
            .keyboardType(.numbersAndPunctuation)
            .submitLabel(.done)
            .focused($isEditingBudget)
            .onSubmit {
                isEditingBudget = false
            }
        }
    }
    
    @ViewBuilder
    private func difficultyPicker() -> some View {
        Picker("Difficulty", selection: $difficulty) {
            ForEach(Mode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
    }
    
    @ViewBuilder
    private func linkButton(
        urlString: String,
        title: String
    ) -> some View {
        Button {
            if let url = URL(string: urlString) {
                openURL(url)
            }
        } label: {
            Label(title, systemImage: "link")
        }
    }
    
    @ViewBuilder
    private func developer() -> some View {
        NavigationLink("Developer") {
            VStack(alignment: .leading) {
                Text(Constants.Manage.aboutDeveloperLine1)
                + Text(Constants.Manage.appName).bold()
                + Text(Constants.Manage.aboutDeveloperLine2)
                
                linkButton(urlString: Constants.Manage.developerURL, title: "Personal Website")
                    .padding(.top, Design.Padding.top)
                
                Spacer()
            }
            .padding()
            .navigationTitle(Constants.Manage.developerName.formatted())
        }
    }
    
    @ViewBuilder
    private func legal() -> some View {
        NavigationLink("Legal") {
            VStack(alignment: .leading) {
                Text(Constants.Manage.legalLine1)
                + Text(Constants.Manage.host).bold()
                + Text(Constants.Manage.legalLine2)
                + Text(Constants.Manage.license).bold()
                + Text(".")
                
                linkButton(urlString: Constants.Manage.repositoryURL, title: "Github Repository")
                    .padding(.top, Design.Padding.top)
                
                Spacer()
            }
            .padding(Design.Padding.standard * 1.89)
            .navigationTitle("Legal")
        }
    }
}

#Preview {
    NavigationStack {
        ManageView(viewModel: .preview)
    }
}

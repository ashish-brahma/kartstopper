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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    
    @AppStorage("budgetAmount") private var budgetLimit: Double = 0.00
    @State private var difficulty: Budget.Mode = .medium
    
    var body: some View {
        Form {
            Section {
                budgetStepper()
                    .disabled(viewModel.budget.isLocked)
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
                
                linkButton(urlString: Constants.Manage.contactURL, title: "Write to us")
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
        .task {
            if viewModel.hasOnboarded {
                viewModel.budget.updateBudgetLock()
            }
            if let mode = viewModel.budget.selectedModes.first {
                difficulty = mode
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Dismiss") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    UserDefaults.standard.set(difficulty.rawValue, forKey: "budgetMode")
                    viewModel.objectWillChange.send()
                    viewModel.budget.updateBudgetSettings()
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark")
                }
            }
        }
    }
    
    @ViewBuilder
    private func budgetStepper() -> some View {
        Stepper {
            budgetField()
        } onIncrement: {
            viewModel.objectWillChange.send()
            budgetLimit += 1
        } onDecrement: {
            viewModel.objectWillChange.send()
            budgetLimit -= 1
            if budgetLimit < 1 {
                budgetLimit = 1
            }
        }
    }
    
    @ViewBuilder
    private func budgetField() -> some View {
        TextField("Budget",
                  value: $budgetLimit,
                  format: .currency(code: locale.currency?.identifier ?? "USD"))
            .keyboardType(.decimalPad)
    }
    
    @ViewBuilder
    private func difficultyPicker() -> some View {
        Picker("Difficulty", selection: $difficulty) {
            ForEach(Budget.Mode.allCases) { mode in
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
            .frame(maxHeight: .infinity)
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
            .frame(maxHeight: .infinity)
            .navigationTitle("Legal")
        }
    }
}

#Preview {
    NavigationStack {
        ManageView(viewModel: .preview)
    }
}

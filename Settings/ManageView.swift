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
    
    @State var budgetAmount: String = ""
    
    private let developerName = PersonNameComponents(
        givenName: "Ashish",
        familyName: "Brahma"
    )
    
    let modes = ["Easy","Medium","Hard"]
    
    var budget: String {
        viewModel.budget
            .formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
    
    var body: some View {
        Form {
            Section {
                budgetStepper()
                    .disabled(viewModel.disableBudget)
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
                developer()
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Preferences")
        .navigationTitleColor(Color.foreground)
        .task {
            viewModel.updateBudgetLock()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
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
            viewModel.budget += 1
        } onDecrement: {
            viewModel.objectWillChange.send()
            viewModel.budget -= 1
            if viewModel.budget < 1 {
                viewModel.budget = 1
            }
        }
    }
    
    @ViewBuilder
    private func budgetField() -> some View {
        TextField("\(budget)", text: $budgetAmount)
            .foregroundStyle(Color.primary)
            .keyboardType(.decimalPad)
            .onChange(of: budgetAmount) { newValue in
                viewModel.budget = Double(newValue) ?? 0.0
            }
    }
    
    @ViewBuilder
    private func difficultyPicker() -> some View {
        Picker("Difficulty", selection: $viewModel.budgetMode) {
            ForEach(modes, id: \.self) { mode in
                Text(mode)
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
            .navigationTitle(developerName.formatted())
        }
    }
}

#Preview {
    NavigationStack {
        ManageView(viewModel: .preview)
    }
}

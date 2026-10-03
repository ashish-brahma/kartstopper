//
//  ManageView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/12/25.
//
//  A SwiftUI view that shows user preferences.

import SwiftUI
import CoreData
internal import Combine

struct ManageView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var navModel: NavigationModel
    @ObservedObject var preferencesModel: PreferencesModel
    
    @Environment(\.locale) private var locale
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        NavigationStack(path: $navModel.presentedCredits) {
            Form {
                Section {
                    NavigationLink {
                        BudgetAmountField(viewModel: viewModel,
                                          preferencesModel: preferencesModel)
                    } label: {
                        if let amount = viewModel.budget.budgetAmount {
                            LabeledContent(
                                "Amount",
                                value: amount,
                                format: .currency(code: locale.currency?.identifier ?? "USD")
                            )
                        } else {
                            LabeledContent("Amount", value: "Setup")
                        }
                    }
                } header: {
                    Text("Monthly Budget")
                } footer: {
                    Text(Constants.Manage.monthlyBudgetFooter)
                }
                
                Section {
                    BudgetModePicker(viewModel: viewModel,
                                     preferencesModel: preferencesModel)
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
                               title: "Send us an email")
                } header: {
                    Text("Help & Support")
                }
                
                Section {
                    NavigationLink("License", value: Credits.license)
                    
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
                case .license:
                    LicenseView()
                case .developer:
                    DeveloperView()
                }
            }
            
        }
    }
}


#Preview {
    ManageView(viewModel: .preview,
               navModel: NavigationModel(),
               preferencesModel: PreferencesModel())
}

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
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var preferencesModel = PreferencesModel()
    
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
                BudgetAmountField(viewModel: viewModel,
                                  preferencesModel: preferencesModel)
                
                BudgetModePicker(viewModel: viewModel,
                                 preferencesModel: preferencesModel)
                
                
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
                        .foregroundStyle(Color.accentColor)
                }
            }
            .task {
                preferencesModel.objectWillChange.send()
                preferencesModel.loadData()
                viewModel.objectWillChange.send()
                
                if let amount = preferencesModel.budgetAmount {
                    viewModel.budget.budgetAmount = amount
                }
                
                if let mode = preferencesModel.selectedMode {
                    viewModel.budget.budgetMode = mode
                }
            }
        }
    }
}


#Preview {
    ManageView(viewModel: .preview,
               navModel: NavigationModel())
}

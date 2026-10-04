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
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showEditor = false
    @State private var field: ManageField?
    
    var body: some View {
        NavigationStack(path: $navModel.presentedCredits) {
            Form {
                Section("Budget") {
                    BudgetAmountNavigationButton(
                        viewModel: viewModel,
                        preferencesModel: preferencesModel,
                        showEditor: $showEditor,
                        field: $field
                    )
                    
                    BudgetModePicker(
                        viewModel: viewModel,
                        preferencesModel: preferencesModel)
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
            .navigationDestination(isPresented: $showEditor) {
                if field == .budgetAmount {
                    EditBudgetAmountView(viewModel: viewModel,
                                         preferencesModel: preferencesModel)
                }
            }
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

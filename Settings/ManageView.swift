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
    @ObservedObject var preferencesModel: PreferencesModel
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showEditor = false
    @State private var field: ManageField?
    
    private var onboardingSteps: Text {
        Text("^[\(viewModel.onboardingSteps) step](inflect: true)").bold()
    }
    
    var body: some View {
        NavigationSplitView {
            Form {
                Section {
                    BudgetAmountNavigationButton(
                        viewModel: viewModel,
                        preferencesModel: preferencesModel,
                        showEditor: $showEditor,
                        field: $field
                    )
                    
                    BudgetModePicker(
                        viewModel: viewModel,
                        preferencesModel: preferencesModel)
                } header: {
                    Text("Budget")
                } footer: {
                    if !viewModel.hasOnboarded {
                        Label("You are \(onboardingSteps) away from setting up your budget.", systemImage: "info.circle")
                            .labelStyle(.titleOnly)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                
                
                Section {
                    NavigationLink("KartStopper") {
                        AppInformationView()
                    }
                    
                    NavigationLink("Developer") {
                        DeveloperInformationView()
                    }
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
        } detail: {
            switch field {
            case .budgetAmount:
                EditBudgetAmountView(viewModel: viewModel,
                                     preferencesModel: preferencesModel)
            case nil:
                ManageView.unavailableView(
                    label: "No selection",
                    symbolName: "filemenu.and.selection",
                    description: "Select a preference to view details."
                )
            }
        }
    }
}


#Preview("Onboarded") {
    ManageView(viewModel: .preview,
               preferencesModel: PreferencesModel())
}

#Preview("Not onboarded") {
    let viewModel = ViewModel(budget: Budget(), hasOnboarded: false)
    ManageView(viewModel: viewModel,
               preferencesModel: PreferencesModel())
}


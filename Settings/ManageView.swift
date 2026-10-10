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
    
    var body: some View {
        NavigationStack {
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
        }
    }
}


#Preview {
    ManageView(viewModel: .preview,
               preferencesModel: PreferencesModel())
}

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
    @Environment(\.horizontalSizeClass) private var horizontalClassSize
    
    @State private var showEditor = false
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    @State private var field: ManageField?
    
    private var onboardingSteps: Text {
        Text("^[\(viewModel.onboardingSteps) step](inflect: true)").bold()
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
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
                    VStack {
                        ManageView.unavailableView(
                            label: "No selection",
                            symbolName: "filemenu.and.selection",
                            description: "Select a preference to view details."
                        )
                        
                        Button("Show preferences") {
                            columnVisibility = NavigationSplitViewVisibility.doubleColumn
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxHeight: proxy.size.height/2)
                }
            }
            .task {
                if horizontalClassSize == .regular
                    && !viewModel.hasOnboarded {
                    field = .budgetAmount
                    columnVisibility = NavigationSplitViewVisibility.doubleColumn
                }
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


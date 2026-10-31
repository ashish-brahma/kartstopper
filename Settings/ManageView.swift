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
    @ObservedObject var navModel: NavigationModel
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) private var horizontalClassSize
    @Environment(\.locale) private var locale
    
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    
    private var onboardingSteps: Text {
        Text("^[\(viewModel.onboardingSteps) step](inflect: true)").bold()
    }
    
    private var currencyCode: String {
        locale.currency?.identifier ?? "USD"
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                List(selection: $navModel.selectedPreference) {
                    Section {
                        NavigationLink(value: ManageNavigation.budgetAmount,
                                       label: amountLabel)
                        
                        NavigationLink(value: ManageNavigation.budgetMode,
                                       label: modeLabel)
                    } header: {
                        Text("Budget")
                    } footer: {
                        if !viewModel.hasOnboarded {
                            Label("You are \(onboardingSteps) away from setting up your budget.", systemImage: "info.circle")
                                .labelStyle(.titleOnly)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .listItemTint(Color(.systemIndigo))
                    
                    Section {
                        NavigationLink("KartStopper",
                                       value: ManageNavigation.appInformation)
                        
                        NavigationLink("Developer",
                                       value: ManageNavigation.developerInformation)
                    } header: {
                        Text("About")
                    }
                }
                .navigationTitle("Preferences")
                .navigationTitleColor(Color.foreground)
            } detail: {
                if let selection = navModel.selectedPreference {
                    switch selection {
                    case .budgetAmount:
                        EditBudgetAmountView(viewModel: viewModel,
                                             preferencesModel: preferencesModel)
                        
                    case .budgetMode:
                        Form {
                            BudgetModePicker(
                                viewModel: viewModel,
                                preferencesModel: preferencesModel
                            )
                        }
                        .navigationTitle("Tracking Difficulty")
                        .navigationBarTitleDisplayMode(.inline)
                        
                    case .appInformation:
                        AppInformationView()
                        
                    case .developerInformation:
                        DeveloperInformationView()
                    }
                }
                
                preferenceUnavailableView(proxy: proxy)
            }
            .task {
                if horizontalClassSize == .regular
                    && !viewModel.hasOnboarded {
                    columnVisibility = NavigationSplitViewVisibility.doubleColumn
                }
            }
        }
    }
    
    @ViewBuilder
    private func preferenceUnavailableView(proxy: GeometryProxy) -> some View {
        if horizontalClassSize == .regular {
            if navModel.selectedPreference == nil {
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
    }
    
    @ViewBuilder
    private func amountLabel() -> some View {
        LabeledContent {
            if let amount = viewModel.budget.budgetAmount {
                Text(amount.formatted(.currency(code: currencyCode)))
            } else {
                Text("Enter an amount")
            }
        } label: {
            Label("Amount", systemImage: "number.square")
        }
    }
    
    @ViewBuilder
    private func modeLabel() -> some View {
        LabeledContent {
            if let mode = viewModel.budget.budgetMode {
                Text(mode.rawValue)
            } else {
                Text("Select a mode")
            }
        } label: {
            Label("Tracking Difficulty", systemImage: "barometer")
        }
    }
}


#Preview("Onboarded") {
    let context = PersistenceController.preview.container.viewContext
    let viewModel = ViewModel.preview
    let preferencesModel = PreferencesModel()
    
    ManageView(viewModel: viewModel,
               preferencesModel: preferencesModel,
               navModel: NavigationModel())
    .task {
        preferencesModel.budgetAmount = viewModel.budget.budgetAmount
        preferencesModel.selectedMode = viewModel.budget.budgetMode
        viewModel.update(context: context)
    }
}

#Preview("Not onboarded") {
    let viewModel = ViewModel(budget: Budget(), hasOnboarded: false)
    ManageView(viewModel: viewModel,
               preferencesModel: PreferencesModel(),
               navModel: NavigationModel())
}


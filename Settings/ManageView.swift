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
    
    private var currencyCode: String {
        locale.currency?.identifier ?? "USD"
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                manageSidebar()
            } detail: {
                manageDetail()
            }
            .task {
                columnVisibility = .doubleColumn
                
                if horizontalClassSize == .regular
                    && navModel.selectedPreference == nil {
                    navModel.selectedPreference = .budgetAmount
                }
            }
        }
    }
    
    @ViewBuilder
    private func manageSidebar() -> some View {
        List(selection: $navModel.selectedPreference) {
            Section {
                NavigationLink(value: ManageNavigation.budgetAmount,
                               label: amountLabel)
                
                NavigationLink(value: ManageNavigation.budgetMode,
                               label: modeLabel)
            } header: {
                Text("Budget")
            }
            
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
    }
    
    private func setupIndicator() -> some View {
        ZStack {
            Circle()
                .fill(Color.red)
            Text("1")
                .font(.caption.bold())
                .foregroundStyle(Color.white)
        }
        .frame(width: 20)
    }
    
    @ViewBuilder
    private func manageDetail() -> some View {
        if let selection = navModel.selectedPreference {
            switch selection {
            case .budgetAmount:
                EditBudgetAmountView(
                    viewModel: viewModel,
                    preferencesModel: preferencesModel
                )
                
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
            HStack(alignment: .center) {
                Image(systemName: "number.square")
                    .foregroundStyle(navModel.selectedPreference == .budgetAmount ? Color.white : Color.accent)
                Text("Amount")
                    .foregroundStyle(navModel.selectedPreference == .budgetAmount ? Color.white : Color.primary)
                
                if viewModel.budget.budgetAmount == nil {
                    setupIndicator()
                }
            }
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
            HStack(alignment: .center) {
                Image(systemName: "barometer")
                    .foregroundStyle(navModel.selectedPreference == .budgetMode ? Color.white : Color.accent)
                
                Text("Tracking Difficulty")
                    .frame(width: 80, alignment: .leading)
                    .foregroundStyle(navModel.selectedPreference == .budgetMode ? Color.white : Color.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                
                if viewModel.budget.budgetMode == nil {
                    setupIndicator()
                }
            }
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
        viewModel.onboardingSteps -= 2
        viewModel.updateOnboardingState()
        viewModel.update(context: context)
    }
}

#Preview("Not onboarded") {
    let viewModel = ViewModel(budget: Budget(), hasOnboarded: false)
    ManageView(viewModel: viewModel,
               preferencesModel: PreferencesModel(),
               navModel: NavigationModel())
}


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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.locale) private var locale
    
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    
    private var currencyCode: String {
        locale.currency?.identifier ?? "USD"
    }
    
    private var isWide: Bool {
        horizontalSizeClass == .regular
    }
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                manageSidebar(proxy: proxy)
            } detail: {
                manageDetail()
            }
            .task {
                columnVisibility = .doubleColumn
                
                if isWide && navModel.selectedPreference == nil {
                    navModel.selectedPreference = .budgetAmount
                }
            }
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func manageSidebar(proxy: GeometryProxy) -> some View {
        List(selection: $navModel.selectedPreference) {
            Section {
                NavigationLink(value: ManageNavigation.budgetAmount) {
                    amountLabel(
                        text: viewModel.budget.budgetAmount?.formatted(
                            .currency(code: currencyCode)
                        ) ?? "Enter an amount",
                        isSelected: navModel.selectedPreference == .budgetAmount
                    )
                }
                
                NavigationLink(value: ManageNavigation.budgetMode) {
                    modeLabel(
                        text: viewModel.budget.budgetMode?.rawValue ?? "Select a mode",
                        isSelected: navModel.selectedPreference == .budgetMode,
                        proxy: proxy
                    )
                }
            } header: {
                Text("Budget")
            }
            
            Section {
                NavigationLink(ManageNavigation.appInformation.name,
                               value: ManageNavigation.appInformation)
                
                NavigationLink(ManageNavigation.developerInformation.name,
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
    private func amountLabel(
        text: String,
        isSelected: Bool
    ) -> some View {
        LabeledContent {
            Text(text)
                .foregroundStyle(isSelected && isWide ? Color.white : Color.secondary)
        } label: {
            labeledContentLabel(
                isSelected: isSelected,
                symbol: ManageNavigation.budgetAmount.symbol,
                fieldName: ManageNavigation.budgetAmount.name,
                isEmpty: viewModel.budget.budgetAmount == nil
            )
        }
    }
    
    @ViewBuilder
    private func modeLabel(
        text: String,
        isSelected: Bool,
        proxy: GeometryProxy
    ) -> some View {
        LabeledContent {
            Text(text)
                .foregroundStyle(isSelected && isWide ? Color.white : Color.secondary)
        } label: {
            labeledContentLabel(
                isSelected: isSelected,
                symbol: ManageNavigation.budgetMode.symbol,
                fieldName: ManageNavigation.budgetMode.name,
                isEmpty: viewModel.budget.budgetMode == nil
            )
            .frame(
                width: isCompact ? proxy.size.width/2.2 : 130,
                alignment: .leading
            )
        }
    }
    
    @ViewBuilder
    private func labeledContentLabel(
        isSelected: Bool,
        symbol: String,
        fieldName: String,
        isEmpty: Bool
    ) -> some View {
        HStack(alignment: .center) {
            Image(systemName: symbol)
                .foregroundStyle(isSelected && isWide ? Color.white : Color.accent)
            
            Text(fieldName)
                .foregroundStyle(isSelected && isWide ? Color.white : Color.primary)
            
            if isEmpty {
                setupIndicator()
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


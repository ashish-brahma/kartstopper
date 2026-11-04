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
    
    // MARK: - Navigation split view
    
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
                    labelView(
                        text: viewModel.budget.budgetAmount?.formatted(
                            .currency(code: currencyCode)
                        ) ?? "Enter an amount",
                        isSelected: navModel.selectedPreference == .budgetAmount,
                        navigation: ManageNavigation.budgetAmount,
                        isEmpty: viewModel.budget.budgetAmount == nil,
                        proxy: proxy
                    )
                }
                
                NavigationLink(value: ManageNavigation.budgetMode) {
                    labelView(
                        text: viewModel.budget.budgetMode?.rawValue ?? "Select a mode",
                        isSelected: navModel.selectedPreference == .budgetMode,
                        navigation: ManageNavigation.budgetMode,
                        isEmpty: viewModel.budget.budgetMode == nil,
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
    
    // MARK: - Label subviews.
    
    @ViewBuilder
    private func labelView(
        text: String,
        isSelected: Bool,
        navigation: ManageNavigation,
        isEmpty: Bool,
        proxy: GeometryProxy
    ) -> some View {
        LabeledContent {
            HStack {
                if !isEmpty {
                    Text(text)
                        .foregroundStyle(
                            getColor(isSelected: isSelected, for: .secondary)
                        )
                }
                
                if isEmpty {
                    setupIndicator()
                }
            }
        } label: {
            labeledContentLabel(
                isSelected: isSelected,
                symbol: navigation.symbol,
                fieldName: navigation.name,
                text: text,
                isEmpty: isEmpty,
                proxy: proxy
            )
        }
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
    private func labeledContentLabel(
        isSelected: Bool,
        symbol: String,
        fieldName: String,
        text: String,
        isEmpty: Bool,
        proxy: GeometryProxy
    ) -> some View {
        HStack(alignment: .center) {
            Image(systemName: symbol)
                .imageScale(isEmpty ? .large : .medium )
                .foregroundStyle(
                    getColor(isSelected: isSelected, for: .accent)
                )
            
            VStack(alignment: .leading) {
                Text(fieldName)
                    .foregroundStyle(
                        getColor(isSelected: isSelected, for: .primary)
                    )
                
                if isEmpty {
                    Text(text)
                        .font(.subheadline)
                        .foregroundStyle(
                            getColor(isSelected: isSelected, for: .secondary)
                        )
                }
            }
        }
    }
    
    private func getColor(
        isSelected: Bool,
        for color: Color
    ) -> Color {
        var selectionColor: Color
        
        if #available(iOS 17, *) {
            selectionColor = color
        } else {
            selectionColor = .white
        }
        
        return isSelected && isWide ? selectionColor : color
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


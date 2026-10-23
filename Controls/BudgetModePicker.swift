//
//  BudgetModePicker.swift
//  KartStopper
//
//  Created by Ashish Brahma on 20/09/26.
//
//  A SwiftUI picker view which sets difficulty level of
//  budget in preferences.

import SwiftUI
import CoreData
internal import Combine

struct BudgetModePicker: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var preferencesModel: PreferencesModel
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Picker(selection: $preferencesModel.selectedMode) {
            ForEach(BudgetMode.allCases) { mode in
                Text(mode.rawValue).tag(mode)
            }
        } label: {
            LabeledContent {
                if viewModel.budget.budgetMode == nil {
                    Text("Select a mode")
                } else {
                    EmptyView()
                }
            } label: {
                Label("Tracking Difficulty", systemImage: "barometer")
            }
        }
        .pickerStyle(.navigationLink)
        .onChange(of: preferencesModel.selectedMode) { _ in
            updateMode()
        }
    }
    
    private func updateMode() {
        guard let savedMode = preferencesModel.selectedMode
        else { return }
        
        let displayMode = viewModel.budget.budgetMode
        
        if savedMode != displayMode {
            preferencesModel.objectWillChange.send()
            preferencesModel.saveData()
            
            viewModel.objectWillChange.send()
            if displayMode == nil {
                viewModel.onboardingSteps -= 1
            }
            viewModel.budget.budgetMode = savedMode
            
            viewModel.validateOnboarding()
            viewModel.updateOnboardingState()
        }
    }
}

#Preview("Onboarded") {
    let context = PersistenceController.preview.container.viewContext
    let viewModel = ViewModel.preview
    List {
        BudgetModePicker(viewModel: viewModel,
                         preferencesModel: PreferencesModel())
    }
    .task {
        viewModel.budget.budgetMode = .medium
        viewModel.update(context: context)
    }
}

#Preview("Not Onboarded") {
    let viewModel = ViewModel(budget: Budget(), hasOnboarded: false)
    List {
        BudgetModePicker(viewModel: viewModel,
                         preferencesModel: PreferencesModel())
    }
}

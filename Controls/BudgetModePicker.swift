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
        Section {
            Picker("Difficulty", selection: $preferencesModel.selectedMode) {
                ForEach(BudgetMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
        } header: {
            Text("Budget Mode")
        } footer: {
            Text(Constants.Manage.budgetModeFooter)
        }
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
            viewModel.budget.budgetMode = savedMode
            viewModel.update(context: viewContext)
        }
    }
}

#Preview {
    List {
        BudgetModePicker(viewModel: .preview,
                         preferencesModel: PreferencesModel())
    }
}

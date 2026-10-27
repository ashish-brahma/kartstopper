//
//  ContentView.swift
//  kartstopper
//
//  Created by Ashish Brahma on 16/09/25.
//
//  A SwiftUI view that shows the main navigation UI.

import SwiftUI
import CoreData
internal import Combine

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var navModel = NavigationModel()
    @SceneStorage("ContentView.navigation") private var navData: Data?
    
    @StateObject var preferencesModel = PreferencesModel()
    @State private var showPreferences = false
    
    var body: some View {
        TabView(selection: $navModel.selectedTab) {
            ForEach(Tabs.allCases) { tab in
                if tab == .manage {
                    primitiveTab(tab: tab)
                        .badge(viewModel.hasOnboarded ? nil : "\(viewModel.onboardingSteps)")
                } else {
                    primitiveTab(tab: tab)
                }
            }
        }
        .task {
            viewModel.loadPreferences(preferencesModel: preferencesModel)
            viewModel.updateOnboardingState()
            viewModel.update(context: viewContext)
            
            // Onboard user if not already done.
            if !viewModel.hasOnboarded {
                navModel.selectedTab = .track
            }
            
            // Restore navigation state.
            if let data = navData {
                navModel.jsonData = data
            }
            
            // Listen for the latest navigation data and store it.
            for await _ in navModel.objectWillChangeSequence {
                navData = navModel.jsonData
            }
        }
        .onChange(of: showPreferences) { newValue in
            if !viewModel.hasOnboarded && newValue {
                navModel.selectedTab = .manage
            }
        }
        .onChange(of: viewModel.hasOnboarded) { boarded in
            if boarded {
                viewModel.objectWillChange.send()
                viewModel.updateOnboardingState()
            }
        }
    }
    
    @ViewBuilder
    private func primitiveTab(tab: Tabs) -> some View {
        tabContent(for: tab)
            .tabItem {
                Label(tab.localizedName,
                      systemImage: tab.symbol)
            }
            .tag(tab)
    }
    
    @ViewBuilder
    private func tabContent(for tab: Tabs) -> some View {
        switch tab {
        case .home:
            CartListView(viewModel: viewModel,
                         navModel: navModel)
        case .track:
            DashboardView(viewModel: viewModel,
                          navModel: navModel,
                          showPreferences: $showPreferences)
        case .manage:
            ManageView(viewModel: viewModel,
                       preferencesModel: preferencesModel)
        }
    }
}

#Preview {
    ContentView(viewModel: .preview)
        .environment(\.managedObjectContext,
                               PersistenceController.preview.container.viewContext)
}

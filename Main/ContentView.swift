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
    
    @State private var showPreferences = false
    
    var body: some View {
        TabView(selection: $navModel.selectedTab) {
            CartListView(viewModel: viewModel, navModel: navModel)
                .tabItem {
                    Label(Tabs.home.localizedName, systemImage: Tabs.home.symbol)
                }
                .tag(Tabs.home)
            
            
            DashboardView(viewModel: viewModel, showPreferences: $showPreferences)
                .tabItem {
                    Label(Tabs.track.localizedName, systemImage: Tabs.track.symbol)
                }
                .tag(Tabs.track)
            
            ManageView(viewModel: viewModel)
                .tabItem {
                    Label(Tabs.manage.localizedName, systemImage: Tabs.manage.symbol)
                }
                .tag(Tabs.manage)
        }
        .task {
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
    }
}

#Preview {
    ContentView(viewModel: .preview)
        .environment(\.managedObjectContext,
                               PersistenceController.preview.container.viewContext)
}

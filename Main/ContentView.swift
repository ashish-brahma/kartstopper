//
//  ContentView.swift
//  kartstopper
//
//  Created by Ashish Brahma on 16/09/25.
//
//  A SwiftUI view that shows the main navigation UI.

import SwiftUI
import CoreData

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private enum Tabs: String {
        case home
        case track
        case manage
    }
    
    @SceneStorage("ContentView.selectedTab") private var selectedTab = Tabs.home
    @State private var showPreferences = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CartListView(viewModel: viewModel)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tabs.home)
            
            NavigationStack {
                DashboardView(viewModel: viewModel,
                              showPreferences: $showPreferences)
            }
            .tabItem {
                Label("Track", systemImage: "chart.bar.xaxis.ascending.badge.clock")
            }
            .tag(Tabs.track)
            
            NavigationStack {
                ManageView(viewModel: viewModel)
            }
            .tabItem {
                Label("Manage", systemImage: "book.and.wrench")
            }
            .tag(Tabs.manage)
        }
        .task {
            viewModel.update(context: viewContext)
            if !viewModel.hasOnboarded {
                selectedTab = .track
            }
        }
        .onChange(of: showPreferences) { newValue in
            if !viewModel.hasOnboarded && newValue {
                selectedTab = .manage
            }
        }
    }
}

#Preview {
    ContentView(viewModel: .preview)
        .environment(\.managedObjectContext,
                               PersistenceController.preview.container.viewContext)
}

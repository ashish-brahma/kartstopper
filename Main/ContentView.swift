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
    
    @State private var showPreferences = false
    
    var body: some View {
        GeometryReader { reader in
            NavigationStack {
                VStack {
                    NavigationBar(viewModel: viewModel,
                                  showPreferences: $showPreferences,
                                  reader: reader)
                    
                    DashboardView(viewModel: viewModel,
                                  showPreferences: $showPreferences,
                                  reader: reader)
                }
                .background(Color.background)
                .navigationTitle("Home")
                .navigationTitleColor(Color.foreground)
                .toolbar(.hidden, for: .navigationBar)
            }
            .sheet(isPresented: $showPreferences,
                   onDismiss: {
                viewModel.update(context: viewContext)
            }) {
                NavigationStack {
                    ManageView(viewModel: viewModel)
                }
            }
        }
    }
}

#Preview {
    ContentView(viewModel: .preview)
        .environment(\.managedObjectContext,
                               PersistenceController.preview.container.viewContext)
}

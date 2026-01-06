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
    var timeRange: ClosedRange<Date> = .startOfMonth(from: .now) ... .now
    
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
                                  timeRange: timeRange,
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
    let dateRange = CDItem.dateRange(context: PersistenceController.preview.container.viewContext)
    
    let start = dateRange.upperBound.addingTimeInterval(-1 * 3600 * 24 * 30)
    
    let end = dateRange.upperBound
    
    ContentView(viewModel: .preview,
                timeRange: start...end)
        .environment(\.managedObjectContext,
                               PersistenceController.preview.container.viewContext)
}

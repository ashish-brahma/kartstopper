//
//  DashboardView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/01/26.
//
//  A SwiftUI view which displays the navigation list.

import SwiftUI
import CoreData

struct DashboardView: View {
    @ObservedObject var viewModel: ViewModel
    
    @Binding var showPreferences: Bool
    var timeRange: ClosedRange<Date> = .startOfMonth(from: .now) ... .now
    let reader: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    var body: some View {
        List {
            if !viewModel.hasOnboarded {
                Section {
                    SetupView(showPreferences: $showPreferences)
                }
                .listRowBackground(Rectangle().fill(.thickMaterial))
            }
            
            Section {
                StatusCardView(reader: reader,
                               viewModel: viewModel)
            }
            
            Section {
                NavigationLink {
                    CartListView(viewModel: viewModel)
                } label: {
                    listsCard()
                }
                
                TopCarts(reader: reader)
            } header: {
                Text(viewModel.totalCarts == 0 ? "Start Listing" : "Continue Listing")
                    .font(.title2.bold())
                    .foregroundStyle(Color.foreground)
            }
            
            Section {
                NavigationLink {
                    ExpenditureDetails()
                } label: {
                    ExpenditureOverview(range: timeRange)
                }
            } header: {
                Text("How You Spent")
                    .font(.title2.bold())
                    .foregroundStyle(Color.foreground)
            }
        }
        .listRowSpacing(Design.Spacing.listRow)
        .scrollContentBackground(.hidden)
        .task {
            viewModel.update(context: viewContext)
        }
    }
    
    @ViewBuilder
    private func listsCard() -> some View {
        VStack(alignment: .leading) {
            Text("Total Carts")
                .font(.callout)
                .foregroundStyle(.secondary)
            
            Text("\(viewModel.totalCarts) Carts")
                .font(.title2.bold())
                .foregroundStyle(Color.foreground)
        }
    }
}

#Preview {
    let dateRange = CDItem.dateRange(context: PersistenceController.preview.container.viewContext)
    
    let start = dateRange.upperBound.addingTimeInterval(-1 * 3600 * 24 * 30)
    
    let end = dateRange.upperBound
    
    GeometryReader { reader in
        NavigationStack {
            DashboardView(viewModel: .preview,
                          showPreferences: .constant(false),
                          timeRange: start...end,
                          reader: reader)
            .background(Color.background)
        }
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

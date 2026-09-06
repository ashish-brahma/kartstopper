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
    @ObservedObject var navModel: NavigationModel
    
    @Binding var showPreferences: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        GeometryReader { reader in
            NavigationStack(path: $navModel.presentedCards) {
                List {
                    if !viewModel.hasOnboarded {
                        Section {
                            SetupView(showPreferences: $showPreferences)
                        }
                        .listRowBackground(Rectangle().fill(.thickMaterial))
                    }
                    
                    Section {
                        TopFrequentCarts(reader: reader)
                    }
                    
                    Section {
                        StatusCardView(viewModel: viewModel)
                        
                        NavigationLink(value: Card.expenses) {
                            ExpenditureOverview(reader: reader)
                        }
                        
                        NavigationLink(value: Card.categories) {
                            CategoriesOverview(reader: reader)
                        }
                    } header: {
                        Text(viewModel.dynamicTitle)
                            .font(.title2.bold())
                            .foregroundStyle(viewModel.fontColor)
                    }
                }
                .listRowSpacing(Design.Spacing.listRow)
                .navigationTitle("Track")
                .navigationTitleColor(Color.foreground)
                .navigationDestination(for: Card.self) { card in
                    switch card {
                    case .expenses:
                        ExpenditureDetails(selectedTimeRange: $navModel.selectedTimeRangeForExpenses)
                    case .categories:
                        CategoryDetails(selectedTimeRange: $navModel.selectedTimeRangeForCategories)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.background)
                .task {
                    viewModel.update(context: viewContext)
                }
            }
        }
    }
}

#Preview {
    DashboardView(viewModel: .preview,
                  navModel: NavigationModel(),
                  showPreferences: .constant(false))
    .background(Color.background)
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

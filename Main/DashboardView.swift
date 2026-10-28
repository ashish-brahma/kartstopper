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
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Binding var showPreferences: Bool
    
    @State private var dismissSetup: Bool = false
    
    private var columns: [GridItem] {
        let gridItem = GridItem(.flexible())
        let count = horizontalSizeClass == .compact ? 1 : 2
        return [GridItem](repeating: gridItem, count: count)
    }
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack(path: $navModel.presentedCards) {
                ScrollView {
                    VStack {
                        if !viewModel.hasOnboarded && !dismissSetup {
                            Section {
                                SetupView(
                                    showPreferences: $showPreferences,
                                    dismiss: $dismissSetup
                                )
                                .padding(Design.Padding.card)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Rectangle().fill(Material.thick))
                                .clipShape(.rect(cornerRadius: Design.cornerRadius))
                                .padding(Design.Padding.standard)
                            }
                        }
                        
                        LazyVGrid(
                            columns: columns,
                            spacing: Design.Spacing.listRow
                        ) {
                            ForEach(Card.allCases) { card in
                                VStack(spacing: Design.Spacing.listRow) {
                                    Section {
                                        statCard(for: card,
                                                 proxy: proxy)
                                        .padding(Design.Padding.card)
                                        .frame(maxWidth: .infinity,
                                               alignment: .leading)
                                        .background(Color(.secondarySystemGroupedBackground))
                                        .clipShape(.rect(cornerRadius: Design.cornerRadius))
                                    }
                                }
                                .padding(Design.Padding.standard)
                            }
                        }
                    }
                    .padding(Design.Padding.standard)
                }
                .background(Color.background)
                .navigationTitle("Track")
                .navigationTitleColor(Color.foreground)
                .navigationDestination(for: Card.self) { card in
                    switch card {
                    case .expenses:
                        ExpenditureDetails(selectedTimeRange: $navModel.selectedTimeRangeForExpenses)
                    case .categories:
                        CategoryDetails(selectedTimeRange: $navModel.selectedTimeRangeForCategories)
                    default:
                        EmptyView()
                    }
                }
                .task {
                    viewModel.update(context: viewContext)
                }
            }
        }
    }
    
    @ViewBuilder
    private func statCard(
        for card: Card,
        proxy: GeometryProxy
    ) -> some View {
        switch card {
        case .topCarts:
            TopFrequentCarts(proxy: proxy)
            
        case .status:
            VStack(alignment: .leading) {
                Text(viewModel.dynamicTitle)
                    .font(.title2.bold())
                    .foregroundStyle(viewModel.fontColor)
                
                Spacer()
                
                StatusCardView(viewModel: viewModel)
                
                Spacer()
            }
            
        case .expenses:
                navigationButton(value: Card.expenses) {
                    ExpenditureOverview(proxy: proxy)
                }
            
        case .categories:
                navigationButton(value: Card.categories) {
                    CategoriesOverview(proxy: proxy)
                }
        }
    }
    
    private func navigationButton(
        value: Card,
        label: () -> some View
    ) -> some View {
        NavigationLink(value: value) {
            HStack {
                label()
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .foregroundStyle(Color.primary)
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

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
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    private var columns: [GridItem] {
        let gridItem = GridItem(.flexible())
        let count = isCompact ? 1 : 2
        return [GridItem](repeating: gridItem, count: count)
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack(path: $navModel.presentedCards) {
                ScrollView {
                    VStack {
                        if !viewModel.hasOnboarded && !dismissSetup {
                            Section {
                                cardView(backgroundFill: Material.thick) {
                                    SetupView(
                                        showPreferences: $showPreferences,
                                        dismiss: $dismissSetup
                                    )
                                }
                            }
                        }
                        
                        LazyVGrid(
                            columns: columns,
                            alignment: .leading,
                            spacing: Design.Spacing.listRow
                        ) {
                            Section {
                                statCard(for: Card.status,
                                         proxy: proxy)
                            } header: {
                                headerText(text: viewModel.dynamicTitle,
                                           color: viewModel.fontColor)
                            }
                            
                            Spacer()
                            
                            Section {
                                statCard(for: Card.topCarts,
                                         proxy: proxy)
                            } header: {
                                headerText(text: "Most Frequent")
                            }
                            
                            Spacer()
                            
                            Section {
                                statCard(for: Card.expenses,
                                         proxy: proxy)
                                
                                statCard(for: Card.categories,
                                         proxy: proxy)
                            } header: {
                                headerText(text: "How You Spent")
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
    
    private func headerText(
        text: String,
        color: Color = Color.foreground
    ) -> some View {
        Text(text)
            .font(.title2.bold())
            .foregroundStyle(color)
            .padding(.horizontal)
    }
    
    private func cardView(
        backgroundFill: some ShapeStyle = Color(.secondarySystemGroupedBackground),
        content: () -> some View
    ) -> some View {
        content()
            .padding(Design.Padding.card)
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            .background(Rectangle().fill(backgroundFill))
            .clipShape(.rect(cornerRadius: Design.cornerRadius))
            .padding(Design.Padding.horizontal)
    }
    
    @ViewBuilder
    private func statCard(
        for card: Card,
        proxy: GeometryProxy
    ) -> some View {
        cardView {
            statCardContent(for: card, proxy: proxy)
        }
    }
    
    @ViewBuilder
    private func statCardContent(
        for card: Card,
        proxy: GeometryProxy
    ) -> some View {
        switch card {
        case .status:
            StatusCardView(viewModel: viewModel)
            
        case .topCarts:
            TopFrequentCarts(proxy: proxy)
            
        case .expenses:
            NavigationLink(value: Card.expenses) {
                ExpenditureOverview(proxy: proxy)
            }
            .foregroundStyle(Color.primary)
            
        case .categories:
            NavigationLink(value: Card.categories) {
                CategoriesOverview(proxy: proxy)
            }
            .foregroundStyle(Color.primary)
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

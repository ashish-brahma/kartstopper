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
    
    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.adaptive(minimum: Design.dashboardColumnMinWidth)),
            count: horizontalSizeClass == .regular ? 2 : 1
        )
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack(path: $navModel.presentedCards) {
                ScrollView {
                    LazyVGrid(columns: columns) {
                        if !viewModel.hasOnboarded {
                            gridLayout(
                                proxy: proxy,
                                style: Material.thickMaterial
                            ) {
                                SetupView(showPreferences: $showPreferences)
                            }
                        }
                        
                        ForEach(Card.allCases) { card in
                            gridLayout(
                                proxy: proxy,
                                style: Color(.secondarySystemGroupedBackground)
                            ) {
                                statCard(for: card,
                                         proxy: proxy)
                            }
                        }
                    }
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
        HStack {
            NavigationLink(value: value) {
                label()
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(Color.primary)
    }
    
    @ViewBuilder
    private func gridLayout(
        proxy: GeometryProxy,
        style: some ShapeStyle,
        _ content: () -> some View
    ) -> some View {
        VStack(alignment: .leading) {
            content()
        }
        .frame(
            minHeight: horizontalSizeClass == .regular ? proxy.size.height/6 :  proxy.size.height/3.8,
            maxHeight: horizontalSizeClass == .regular ? proxy.size.height/3 :  proxy.size.height/1.6,
            alignment: .topLeading
        )
        .padding(Design.Padding.standard * 2)
        .background {
            RoundedRectangle(cornerRadius: Design.cardRadius)
                .fill(style)
        }
        .padding(.horizontal, Design.Padding.horizontal * 4)
        .padding(.vertical, Design.Padding.vertical)
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

//
//  CartListView.swift
//  kartstopper
//
//  Created by Ashish Brahma on 27/11/25.
//
//  A SwiftUI view that shows the carts list.

import SwiftUI
import CoreData
internal import Combine
internal import OSLog

struct CartListView: View {
    let logger = PersistenceController.shared.logger
    
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var navModel: NavigationModel
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    @SectionedFetchRequest<String, CDCart>(
        sectionIdentifier: \.sectionDate,
        sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: false)]
    )
    private var carts: SectionedFetchResults<String, CDCart>
    
    @State private var showAddCart = false
    @State private var showEditCart = false
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    
    // MARK: - Navigation split view
    
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                cartsSidebar()
            } detail: {
                cartsDetail(proxy: proxy)
            }
            .overlay {
                cartsUnavailableOverlay()
            }
            .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    private func cartsSidebar() -> some View {
        cartsList()
            .scrollContentBackground(.hidden)
            .background {
                Rectangle()
                    .fill(Color.background)
                    .overlay {
                        if colorScheme == .light {
                            Rectangle()
                                .fill(Material.thin)
                        }
                    }
                    .ignoresSafeArea()
            }
    }
    
    @ViewBuilder
    private func cartsDetail(proxy: GeometryProxy) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.background)
                .ignoresSafeArea()
            
            
            if let cart = navModel.selectedCart {
                ChecklistView(cart: cart,
                              viewModel: viewModel,
                              navModel: navModel)
            }
            
            cartsUnavailableDetail(proxy: proxy)
        }
    }
    
    // MARK: - List view
    
    @ViewBuilder
    private func cartsList() -> some View {
        List(selection: $navModel.selectedCart) {
            ForEach(carts) { section in
                Section(header: Text(section.id)) {
                    ForEach(section) { cart in
                        CartNavigationButton(
                            navModel: navModel,
                            cart: cart,
                            showEditCart: $showEditCart,
                            onDelete: { deleteCart(cart) }
                        )
                        .listRowBackground(navModel.selectedCart == cart ? Color.blue : Color(.secondarySystemGroupedBackground))
                    }
                    .onDelete { indexSet in
                        deleteCart(in: Array(section),
                                   at: indexSet)
                    }
                }
            }
            
            if showAddCart {
                AddCartView(viewModel: viewModel,
                            showAddCart: $showAddCart)
            }
        }
        .overlay {
            if !showAddCart
                && viewModel.totalCarts != 0
                && carts.isEmpty {
                ContentView.searchUnavailableView
            }
        }
        .searchable(text: $viewModel.cartQuery, placement: .navigationBarDrawer)
        .navigationTitle("Carts")
        .navigationTitleColor(Color.foreground)
        .textInputAutocapitalization(.never)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
                    .disabled(carts.isEmpty)
            }
            ToolbarItem(placement: .primaryAction) {
                AddToolbarButton(entityName: "cart") {
                    showAddCart = true
                }
                .disabled(showAddCart)
            }
        }
        .sheet(isPresented: $showEditCart) {
            if let selection = navModel.selectedCart {
                EditCartView(viewModel: viewModel,
                             cart: selection)
            }
        }
        .onChange(of: viewModel.cartQuery) { newValue in
            carts.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@", viewModel.cartQuery)
        }
        .onChange(of: viewModel.totalCarts) { newCount in
            selectLatestCart()
        }
        .task {
            selectLatestCart()
        }
    }
    
    private func selectLatestCart() {
        if horizontalSizeClass == .regular {
            if let section = carts.first,
               let cart = section.first {
                navModel.selectedCart = cart
            }
        }
    }
    
    // MARK: - Content unavailable views
    
    @ViewBuilder
    private func cartsUnavailableDetail(proxy: GeometryProxy) -> some View {
        if horizontalSizeClass == .regular {
            
            if !showAddCart && viewModel.totalCarts == 0 {
                VStack {
                    CartListView.unavailableView(
                        label: "No Carts",
                        symbolName: "cart.badge.plus",
                        description: "New carts you add will group items."
                    )
                    .padding(.bottom, Design.Padding.bottom)
                    
                    Button("Let's  start.") {
                        columnVisibility = NavigationSplitViewVisibility.doubleColumn
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxHeight: proxy.size.height/2)
            }
        }
    }
    
    @ViewBuilder
    private func cartsUnavailableOverlay() -> some View {
        if horizontalSizeClass == .compact
            && verticalSizeClass == .regular {
            
            if !showAddCart && viewModel.totalCarts == 0 {
                CartListView.unavailableView(
                    label: "No Carts",
                    symbolName: "cart.badge.plus",
                    description: "New carts you add will appear here."
                )
            }
        }
    }
    
    // MARK: - Core Data methods
    
    private func saveContext(cart: CDCart) {
        do {
            try viewContext.save()
        } catch {
            logger.error("Failed to delete cart. \(error.localizedDescription)")
        }
    }
    
    private func deleteCart(
        in section: [CDCart],
        at offsets: IndexSet
    ) {
        withAnimation {
            offsets.map { section[$0] }.forEach(deleteCart)
        }
    }
    
    private func deleteCart(_ cart: CDCart) {
        viewModel.objectWillChange.send()
        if cart.objectID == navModel.selectedCart?.objectID {
            navModel.selectedCart = nil
        }
        viewContext.delete(cart)
        saveContext(cart: cart)
        viewModel.update(context: viewContext)
    }
}

#Preview {
    let result = PersistenceController.preview
    let viewContext = result.container.viewContext
    let model: ViewModel = .preview
    
    CartListView(viewModel: model,
                 navModel: NavigationModel())
    .task {
        model.update(context: viewContext)
    }
    .environment(\.managedObjectContext, viewContext)
}

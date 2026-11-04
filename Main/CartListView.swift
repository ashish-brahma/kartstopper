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
    @Environment(\.colorScheme) private var colorScheme
    
    @SectionedFetchRequest<String, CDCart>(
        sectionIdentifier: \.sectionDate,
        sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: false)]
    )
    private var carts: SectionedFetchResults<String, CDCart>
    
    @State private var showAddCart = false
    @State private var showEditCart = false
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    
    private var isWide: Bool {
        horizontalSizeClass == .regular
    }
    
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    // MARK: - Navigation split view
    
    var body: some View {
        GeometryReader { proxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                cartsSidebar()
            } detail: {
                cartsDetail(proxy: proxy)
            }
            .overlay {
                if showAddCart {
                    AddCartView(
                        viewModel: viewModel,
                        showAddCart: $showAddCart,
                        proxy: proxy
                    )
                }
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
            
            if !showAddCart
                && viewModel.totalCarts == 0
                && isWide {
                    cartsUnavailableDetail(proxy: proxy)
            }
        }
    }
    
    @ViewBuilder
    private func cartsUnavailableDetail(proxy: GeometryProxy) -> some View {
        VStack(alignment: .center) {
            CartListView.unavailableView(
                label: "No Carts",
                symbolName: "cart.badge.plus",
                description: "New carts you add will group items."
            )
            .padding(.bottom, Design.Padding.bottom)
            
            if columnVisibility == .detailOnly {
                Button("Let's  start") {
                    columnVisibility = .doubleColumn
                }
                .buttonStyle(.bordered)
            } else {
                Text("Tap on plus button.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxHeight: proxy.size.height/2)
    }
    
    // MARK: - List view
    
    @ViewBuilder
    private func cartsList() -> some View {
        List(selection: $navModel.selectedCart) {
            ForEach(carts) { section in
                Section(header: Text(section.id)) {
                    ForEach(section) { cart in
                        NavigationLink(value: cart) {
                            CartRowView(
                                cart: cart,
                                navModel: navModel,
                                isSidebarAvailable: isWide
                            )
                        }
                        .swipeActions(edge: .trailing) {
                            DeleteSwipeButton {
                                deleteCart(cart)
                            }
                            EditSwipeButton {
                                navModel.cartToEdit = cart
                                showEditCart = true
                            }
                        }
                    }
                    .onDelete { indexSet in
                        deleteCart(in: Array(section),
                                   at: indexSet)
                    }
                }
            }
        }
        .id(viewModel.totalCarts)
        .overlay {
            if !showAddCart {
                if viewModel.totalCarts == 0 {
                    if isCompact {
                        CartListView.unavailableView(
                            label: "No Carts",
                            symbolName: "cart.badge.plus",
                            description: "New carts you add will appear here."
                        )
                    }
                } else if carts.isEmpty {
                    ContentView.searchUnavailableView
                }
            }
        }
        .searchable(text: $viewModel.cartQuery, placement: .navigationBarDrawer)
        .navigationTitle("Carts")
        .navigationTitleColor(Color.foreground)
        .textInputAutocapitalization(.never)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .primaryAction) {
                AddToolbarButton(entityName: "cart") {
                    showAddCart = true
                }
                .disabled(showAddCart && !viewModel.cartQuery.isEmpty)
            }
        }
        .sheet(isPresented: $showEditCart) {
            if let selection = navModel.cartToEdit {
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
        .onChange(of: navModel.selectedCart) { cart in
            if cart == nil {
                selectLatestCart()
            }
        }
        .task {
            if navModel.selectedCart == nil {
                selectLatestCart()
            }
        }
    }
    
    private func selectLatestCart() {
        if isWide {
            if let section = carts.first,
               let cart = section.first {
                navModel.selectedCart = cart
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

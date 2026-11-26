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
    @StateObject var validator = ValidatorModel()
    
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
    @State private var isEditActive = false
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    
    private var allSelected: Bool {
        if viewModel.totalCarts > 0 {
            return navModel.selectedCarts.count == viewModel.totalCarts
        } else {
            return false
        }
    }
    
    private var noneSelected: Bool {
        navModel.selectedCarts.isEmpty
    }
    
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
            
            
            if let cart = navModel.selectedCarts.first {
                ChecklistView(cart: cart,
                              showEditCart: $showEditCart,
                              viewModel: viewModel,
                              navModel: navModel,
                              validator: validator)
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
        List(selection: $navModel.selectedCarts) {
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
                                withAnimation {
                                    deleteCart(cart)
                                }
                            }
                            EditSwipeButton {
                                navModel.cartToEdit = cart
                                showEditCart = true
                            }
                        }
                    }
//                    .onDelete { indexSet in
//                        deleteCart(in: Array(section),
//                                   at: indexSet)
//                    }
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
        .navigationBarTitleDisplayMode(isEditActive ? .inline : .large)
        .textInputAutocapitalization(.never)
        .toolbar {
            if isEditActive {
                ToolbarTitleMenu {
                    Button(allSelected ? "Deselect All" : "Select All") {
                        if allSelected {
                            navModel.selectedCarts = Set<CDCart>()
                        } else {
                            carts.forEach {
                                $0.forEach {
                                    navModel.selectedCarts.insert($0)
                                }
                            }
                        }
                    }
                    .disabled(viewModel.totalCarts == 0)
                }
            }
            toolbarContent()
        }
        .environment(\.editMode, .constant(isEditActive ? EditMode.active : EditMode.inactive))
        .sheet(isPresented: $showAddCart) {
            AddCartView(
                viewModel: viewModel,
                validator: validator,
                showAddCart: $showAddCart
            )
            .presentationDetents([.fraction(0.7)])
        }
        .sheet(isPresented: $showEditCart) {
            if let selection = navModel.cartToEdit {
                EditCartView(viewModel: viewModel,
                             validator: validator,
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
        if isWide && !isEditActive && noneSelected {
            if let section = carts.first,
               let cart = section.first {
                navModel.selectedCarts.insert(cart)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if isEditActive {
                ConfirmToolbarButton {
                    withAnimation {
                        isEditActive = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            } else {
                Button("Select") {
                    withAnimation {
                        isEditActive = true
                    }
                }
            }
        }
        if isEditActive {
            ToolbarItem(placement: .principal) {
                Text("\(navModel.selectedCarts.count) selected")
                    .foregroundStyle(.accent)
            }
            ToolbarItem(placement: .destructiveAction) {
                Button("Delete", systemImage: "trash") {
                    navModel.selectedCarts.forEach { cart in
                        withAnimation {
                            deleteCart(cart)
                        }
                    }
                }
                .disabled(navModel.selectedCarts.count == 0)
            }
        } else {
            ToolbarItem(placement: .primaryAction) {
                AddToolbarButton(entityName: "cart") {
                    showAddCart = true
                }
                .disabled(showAddCart && !viewModel.cartQuery.isEmpty)
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
    
//    private func deleteCart(
//        in section: [CDCart],
//        at offsets: IndexSet
//    ) {
//        withAnimation {
//            offsets.map { section[$0] }.forEach(deleteCart)
//        }
//    }
    
    private func deleteCart(_ cart: CDCart) {
        viewModel.objectWillChange.send()
        if navModel.selectedCarts.map(\.objectID).contains(cart.objectID) {
            navModel.selectedCarts.remove(cart)
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
    
    CartListView(
        viewModel: model,
        navModel: NavigationModel()
    )
    .task {
        model.update(context: viewContext)
    }
    .environment(\.managedObjectContext, viewContext)
}

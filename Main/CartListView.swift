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

struct CartListView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var navModel: NavigationModel
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @SectionedFetchRequest<String, CDCart>(
        sectionIdentifier: \.sectionDate,
        sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)]
    )
    private var carts: SectionedFetchResults<String, CDCart>
    
    @State private var showAddCart = false
    @State private var showEditCart = false
    
    @State private var name = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationStack(path: $navModel.presentedCarts) {
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
                        }
                        .onDelete { indexSet in
                            deleteCart(in: Array(section),
                                       at: indexSet)
                        }
                    }
                }
                
                if showAddCart {
                    Section {
                        AddCartView(name: $name,
                                    notes: $notes)
                    }
                    .listRowBackground(Rectangle().fill(Color(.secondarySystemGroupedBackground)))
                }
            }
            .overlay {
                if !showAddCart {
                    if viewModel.totalCarts == 0 {
                        ContentView.unavailableView(
                            label: "No Carts",
                            symbolName: "cart.badge.plus",
                            description: "New carts you add will appear here."
                        )
                    } else if carts.isEmpty {
                        ContentView.searchUnavailableView
                    }
                }
            }
            .searchable(text: $viewModel.cartQuery, placement: .navigationBarDrawer)
            .onChange(of: viewModel.cartQuery) { newValue in
                carts.nsPredicate = newValue.isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@", viewModel.cartQuery)
            }
            .navigationTitle("Carts")
            .navigationTitleColor(Color.foreground)
            .navigationDestination(for: CDCart.self) { cart in
                ChecklistView(cart: cart,
                              viewModel: viewModel,
                              navModel: navModel)
            }
            .textInputAutocapitalization(.never)
            .scrollContentBackground(.hidden)
            .background(Color.background)
            .toolbar {
                CartsToolbar(viewModel: viewModel,
                             showAddCart: $showAddCart,
                             cartsEmpty: .constant(carts.isEmpty),
                             name: $name,
                             notes: $notes)
            }
            .sheet(isPresented: $showEditCart) {
                if let selection = navModel.selectedCart {
                    EditCartView(cart: selection)
                }
            }
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError)")
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
        saveContext()
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

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
                            CartNavLink(for: cart)
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
                    .listRowBackground(Rectangle().fill(.ultraThickMaterial))
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
                              viewModel: viewModel)
            }
            .textInputAutocapitalization(.never)
            .scrollContentBackground(.hidden)
            .background(Color.background)
            .toolbar {
                editorToolbar()
            }
            .task {
                viewModel.update(context: viewContext)
            }
        }
    }
    
    // MARK: - View Builder Methods
    
    @ViewBuilder
    private func CartNavLink(
        for cart: CDCart
    ) -> some View {
        Button {
            navModel.selectedCart = cart
            withAnimation {
                navModel.presentedCarts.append(cart)
            }
        } label: {
            CartRowView(cart: cart)
        }
        .swipeActions(edge: .trailing) {
            DeleteSwipeButton { deleteCart(cart) }
        }
        .swipeActions(edge: .trailing) {
            EditSwipeButton {
                navModel.selectedCart = cart
                showEditCart = true
            }
        }
        .sheet(isPresented: $showEditCart) {
            if let selection = navModel.selectedCart {
                NavigationStack {
                    EditCartView(cart: selection)
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private func editorToolbar() -> some ToolbarContent {
        if showAddCart {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    showAddCart = false
                } label: {
                    Label("Cancel", systemImage: "xmark")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    addCart()
                    showAddCart = false
                } label: {
                    Label("Done", systemImage: "checkmark")
                }
                .disabled(name.isEmpty)
            }
        } else {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
                    .disabled(carts.isEmpty)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddCart = true
                } label: {
                    Label("Add cart", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .disabled(showAddCart)
            }
        }
    }
    
    // MARK: - Core Data Methods
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError)")
        }
    }
    
    private func addCart() {
        withAnimation {
            let newCart = CDCart(context: viewContext)
            newCart.id = Int32(viewModel.totalCarts + 1)
            newCart.name = name
            newCart.timestamp = Date()
            newCart.notes = notes
            saveContext()
            viewModel.update(context: viewContext)
        }
    }
    
    private func deleteCart(
        in section: [CDCart],
        at offsets: IndexSet) {
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
    CartListView(viewModel: .preview, navModel: NavigationModel())
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}

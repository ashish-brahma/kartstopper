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
    @Environment(\.managedObjectContext) private var viewContext

    @SectionedFetchRequest<String, CDCart>(
        sectionIdentifier: \.sectionDate,
        sortDescriptors: [NSSortDescriptor(keyPath: \CDCart.id, ascending: true)]
    )
    private var carts: SectionedFetchResults<String, CDCart>
    
    @State private var selection: CDCart?
    @State private var showAddCart = false
    @State private var showEditCart = false
    
    @State private var name = ""
    @State private var notes = ""
    
    var body: some View {
        VStack {
            List(selection: $selection) {
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
            .textInputAutocapitalization(.never)
            .scrollContentBackground(.hidden)
            .toolbar {
                editorToolbar()
            }
            .task {
                viewModel.update(context: viewContext)
            }
            
            addButtonView()
        }
        .background(Color.background)
    }
    
    // MARK: - View Builder Methods
    
    @ViewBuilder
    private func CartNavLink(
        for cart: CDCart
    ) -> some View {
        NavigationLink {
            ChecklistView(cart: cart,
                          viewModel: viewModel)
        } label: {
            CartRowView(cart: cart)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteCart(cart)
            } label: {
                Label("Delete", systemImage: "trash")
                    .labelStyle(.iconOnly)
            }
        }
        .swipeActions(edge: .trailing) {
            Button {
                selection = cart
                showEditCart = true
            } label: {
                Label("Edit Cart Details", systemImage: "pencil")
                    .tint(.edit)
                    .labelStyle(.iconOnly)
            }
        }
        .sheet(isPresented: $showEditCart) {
            if let selection = selection {
                NavigationStack {
                    EditCartView(cart: selection)
                }
            }
        }
    }
    
    @ViewBuilder
    private func addButtonView() -> some View {
        HStack {
            Spacer()
            Button {
                showAddCart = true
            } label: {
                Label("Add cart", systemImage: "plus")
                    .labelStyle(.iconOnly)
                    .imageScale(.large)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.circle)
            .padding(Design.Padding.trailing)
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
            ToolbarItem(placement: .primaryAction) {
                EditButton()
                    .disabled(carts.isEmpty)
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
        if cart.objectID == selection?.objectID {
            selection = nil
        }
        viewContext.delete(cart)
        saveContext()
        viewModel.update(context: viewContext)
    }
}

#Preview {
    NavigationStack {
        CartListView(viewModel: .preview)
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

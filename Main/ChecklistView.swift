//
//  ChecklistView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 02/10/25.
//
//  A SwiftUI view that shows the checklist.

import SwiftUI
import CoreData
internal import Combine

struct ChecklistView: View {
    var cart: CDCart
    
    @ObservedObject var viewModel: ViewModel
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest private var itemList: FetchedResults<CDItem>
    
    var cartPredicate: NSPredicate {
        return NSPredicate(format: "cart.name = %@", cart.name ?? "")
    }
    
    var searchPredicate: NSPredicate {
        let itemListPredicate = NSPredicate(format: "name CONTAINS[cd] %@", viewModel.itemQuery)
        let compoundPredicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [itemListPredicate, cartPredicate]
        )
        return compoundPredicate
    }
    
    private var totalItems: Int {
        CDCart.getTotalItems(for: cart, context: viewContext)
    }
    
    @State private var selection: CDItem?
    @State private var showAddItem = false
    @State private var showEditCart = false
    @State private var showEditItem = false
    @State private var showItemInfo = false
    
    init(
        cart: CDCart,
        viewModel: ViewModel
    ) {
        self.cart = cart
        self.viewModel = viewModel
        
        self._itemList = FetchRequest<CDItem>(
            sortDescriptors: [NSSortDescriptor(keyPath: \CDItem.id, ascending: true)],
            predicate: NSPredicate(format: "cart.name = %@", cart.name ?? "")
        )
    }
    
    var body: some View {
        GeometryReader { reader in
            List(selection: $selection) {
                ForEach(itemList) { item in
                    itemRowBuilder(item: item,
                                   reader: reader)
                }
                .onDelete(perform: deleteItem(at:))
                .onMove(perform: move)
            }
            .overlay {
                if totalItems == 0 {
                    ChecklistView.unavailableView(
                        label: "No Items",
                        symbolName: "note.text.badge.plus",
                        description: "New items you add will appear here."
                    )
                } else if itemList.isEmpty {
                    ChecklistView.unavailableView(
                        label: "No Results",
                        symbolName: "magnifyingglass",
                        description: "Tap on return to search online or try a new search."
                    )
                }
            }
            .searchable(text: $viewModel.itemQuery, prompt: "Find an item")
            .onChange(of: viewModel.itemQuery) { newValue in
                itemList.nsPredicate = newValue.isEmpty ? cartPredicate : searchPredicate
            }
            .textInputAutocapitalization(.never)
            .navigationTitle(cart.displayName)
            .scrollContentBackground(.hidden)
            .background(Color.background)
            .toolbar {
                editorToolbar()
            }
            .sheet(isPresented: $showAddItem) {
                NavigationStack {
                    AddItemView(cart: cart, viewModel: viewModel)
                }
            }
            .sheet(isPresented: $showEditCart) {
                NavigationStack {
                    EditCartView(cart: cart)
                }
            }
        }
    }
    
    // MARK: - View Builder Methods
    
    @ViewBuilder
    private func itemRowBuilder(
        item: CDItem,
        reader: GeometryProxy
    ) -> some View {
        itemNavLabel(for: item, reader: reader)
            .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                    deleteItem(item)
                } label: {
                    Label("Delete", systemImage: "trash")
                        .labelStyle(.iconOnly)
                }
            }
            .swipeActions(edge: .trailing) {
                Button {
                    selection = item
                    showEditItem = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .tint(.edit)
                        .labelStyle(.iconOnly)
                }
            }
            .sheet(isPresented: $showEditItem) {
                if let selection = selection {
                    NavigationStack {
                        EditItemView(item: selection)
                    }
                }
            }
            .sheet(isPresented: $showItemInfo) {
                if let selection = selection {
                    NavigationStack {
                        ItemDetailView(imageURL: selection.imageURL,
                                       name: selection.displayName,
                                       price: selection.price,
                                       notes: selection.displayNotes)
                        .presentationDragIndicator(.visible)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showEditItem = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                        .tint(.edit)
                                        .labelStyle(.iconOnly)
                                }
                            }
                        }
                    }
                }
            }
    }
    
    @ViewBuilder
    private func itemNavLabel(
        for item: CDItem,
        reader: GeometryProxy
    ) -> some View {
        VStack(alignment: .leading) {
            HStack {
                displayStatus(for: item)
                    .padding(.trailing, Design.Padding.trailing)
                    .onTapGesture {
                        toggleStatus(for: item)
                    }
                
                VStack(alignment: .leading) {
                    ItemRowView(imageURL: item.imageURL,
                                date: item.displayDate,
                                name: item.displayName,
                                price: item.price,
                                reader: reader,
                                isSearching: false)
                    .frame(height: reader.size.height/6)
                    
                    quantityStepper(for: item)
                        .frame(width: reader.size.width/2)
                        .padding(.horizontal, Design.Padding.horizontal)
                }
                
                Spacer()
                
                infoButton(for: item)
            }
        }
    }
    
    @ViewBuilder
    private func displayStatus(for item: CDItem) -> some View {
        Label("Checkcircle",
              systemImage: item.isComplete ? "checkmark.circle.fill" : "circle")
        .imageScale(.large)
        .labelStyle(.iconOnly)
        .foregroundStyle(Color.accentColor)
    }
    
    @ViewBuilder
    private func quantityStepper(for item: CDItem) -> some View {
        Stepper {
            Text("Quantity: \(item.quantity)")
                .foregroundStyle(.secondary)
        } onIncrement: {
            viewModel.objectWillChange.send()
            item.quantity += 1
            saveContext()
        } onDecrement: {
            viewModel.objectWillChange.send()
            item.quantity -= 1
            if item.quantity < 1 {
                item.quantity = 1
            }
            saveContext()
        }
    }
    
    @ViewBuilder
    private func infoButton(for item: CDItem) -> some View {
        Button {
            selection = item
            showItemInfo = true
        } label: {
            Label("Info", systemImage: "info.circle")
                .imageScale(.large)
                .tint(.info)
                .labelStyle(.iconOnly)
        }
    }
    
    @ToolbarContentBuilder
    private func editorToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            EditButton()
                .disabled(itemList.isEmpty)
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.objectWillChange.send()
                showAddItem.toggle()
            } label: {
                Label("Add item", systemImage: "plus")
            }
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.objectWillChange.send()
                showEditCart.toggle()
            } label: {
                Label("Edit cart details", systemImage: "pencil")
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
    
    private func deleteItem(at offsets: IndexSet) {
        withAnimation {
            offsets.map { itemList[$0] }.forEach(deleteItem)
            saveContext()
        }
    }
    
    private func deleteItem(_ item: CDItem) {
        viewModel.objectWillChange.send()
        viewContext.delete(item)
        saveContext()
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        viewModel.objectWillChange.send()
        var itemArray = Array(itemList)
        itemArray.move(fromOffsets: source, toOffset: destination)
        for i in 0..<itemArray.count {
            itemArray[i].id = Int32(i)
        }
        saveContext()
    }
    
    func toggleStatus(for item: CDItem) {
        viewModel.objectWillChange.send()
        item.isComplete.toggle()
        saveContext()
    }
}

#Preview {
    NavigationStack {
        ChecklistView(cart: .preview, viewModel: .preview)
            .environment(\.managedObjectContext,
                          PersistenceController.preview.container.viewContext)
    }
}

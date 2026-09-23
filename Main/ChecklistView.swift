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
internal import OSLog

struct ChecklistView: View {
    var cart: CDCart
    
    let logger = PersistenceController.shared.logger
    
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var navModel: NavigationModel
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Namespace var bottomID
    
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
    
    @State private var showEditItem = false
    @State private var showItemInfo = false
    
    @State private var name = ""
    @State private var price: Double? = 0.00
    
    init(
        cart: CDCart,
        viewModel: ViewModel,
        navModel: NavigationModel
    ) {
        self.cart = cart
        self.viewModel = viewModel
        self.navModel = navModel
        
        self._itemList = FetchRequest<CDItem>(
            sortDescriptors: [NSSortDescriptor(keyPath: \CDItem.id, ascending: true)],
            predicate: NSPredicate(format: "cart.name = %@", cart.name ?? "")
        )
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollProxy in
                List(selection: $navModel.selectedItem) {
                    ForEach(itemList) { item in
                        ItemRowView(
                            viewModel: viewModel,
                            navModel: navModel,
                            item: item,
                            showItemInfo: $showItemInfo,
                            reader: geometryProxy,
                            deleteAction: { deleteItem(item) }
                        )
                    }
                    .onDelete(perform: deleteItem(at:))
                    .onMove(perform: move)
                    .task {
                        withAnimation {
                            scrollProxy.scrollTo(bottomID)
                        }
                    }
                    
                    Section {
                        AddItemView(viewModel: viewModel,
                                    name: $name,
                                    price: $price,
                                    cart: cart)
                        .id(bottomID)
                    }
                    .listRowBackground(Rectangle().fill(Color(.secondarySystemGroupedBackground)))
                }
                .overlay {
                    if totalItems != 0 && itemList.isEmpty {
                        ChecklistView.searchUnavailableView
                    }
                }
                .searchable(text: $viewModel.itemQuery)
                .onChange(of: viewModel.itemQuery) { newValue in
                    itemList.nsPredicate = newValue.isEmpty ? cartPredicate : searchPredicate
                }
                .textInputAutocapitalization(.never)
                .navigationTitle(cart.displayName)
                .navigationTitleColor(Color.foreground)
                .scrollContentBackground(.hidden)
                .background(Color.background)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        EditButton()
                            .disabled(itemList.isEmpty)
                    }
                }
                .sheet(isPresented: $showItemInfo) {
                    if let selection = navModel.selectedItem {
                        EditItemView(item: selection)
                    }
                }
            }
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        withAnimation {
            offsets.map { itemList[$0] }.forEach(deleteItem)
        }
    }
    
    private func deleteItem(_ item: CDItem) {
        viewModel.objectWillChange.send()
        if item.objectID == navModel.selectedItem?.objectID {
            navModel.selectedItem = nil
        }
        viewContext.delete(item)
        
        do {
            try viewContext.save()
        } catch {
            if !item.isDeleted {
                logger.error("Failed to delete item. \(error.localizedDescription)")
            }
        }
    }
    
    private func move(
        from source: IndexSet,
        to destination: Int
    ) {
        withAnimation {
            var itemArray = Array(itemList)
            
            itemArray.move(fromOffsets: source,
                           toOffset: destination)
            
            for i in 0..<itemArray.count {
                itemArray[i].id = Int32(i)
            }
            
            do {
                try viewContext.save()
            } catch {
                logger.error("Failed to move(rearrange) items. \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    let result = PersistenceController.preview
    let viewContext = result.container.viewContext
    
    let request = CDCart.fetchRequest()
    let cart = try! viewContext.fetch(request).first { $0.id == 0 }
    
    NavigationStack {
        ChecklistView(cart: cart!,
                      viewModel: .preview,
                      navModel: NavigationModel())
    }
    .environment(\.managedObjectContext, viewContext)
}

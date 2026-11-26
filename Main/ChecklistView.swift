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
    @ObservedObject var validator: ValidatorModel
    
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
    
    @Binding var showEditCart: Bool
    @State private var showAddItem = false
    @State private var showEditItem = false
    @State private var showItemInfo = false
    @State private var isEditActive = false
    
    private var allSelected: Bool {
        totalItems > 0 ? navModel.selectedItems.count == totalItems : false
    }
    
    init(
        cart: CDCart,
        showEditCart: Binding<Bool>,
        viewModel: ViewModel,
        navModel: NavigationModel,
        validator: ValidatorModel
    ) {
        self.cart = cart
        _showEditCart = showEditCart
        self.viewModel = viewModel
        self.navModel = navModel
        self.validator = validator
        
        self._itemList = FetchRequest<CDItem>(
            sortDescriptors: [NSSortDescriptor(keyPath: \CDItem.id, ascending: true)],
            predicate: NSPredicate(format: "cart.name = %@", cart.name ?? "")
        )
    }
    
    // MARK: - Views
    
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollProxy in
                List(selection: $navModel.selectedItems) {
                    ForEach(itemList) { item in
                        ItemRowView(
                            viewModel: viewModel,
                            navModel: navModel,
                            item: item,
                            showItemInfo: $showItemInfo,
                            proxy: geometryProxy
                        )
                        .listRowBackground(Color.clear)
                        .swipeActions(edge: .trailing) {
                            DeleteSwipeButton {
                                deleteItem(item)
                            }
                            
                            EditSwipeButton {
                                navModel.itemToEdit = item
                                showItemInfo = true
                            }
                        }
                    }
//                    .onDelete(perform: deleteItem(at:))
                    .onMove(perform: move)
                    .task {
                        withAnimation {
                            scrollProxy.scrollTo(bottomID)
                        }
                    }
                    .onChange(of: showAddItem) { newValue in
                        if !newValue {
                            withAnimation {
                                scrollProxy.scrollTo(bottomID)
                            }
                        }
                    }
                    
                    if !showAddItem && viewModel.itemQuery.isEmpty {
                        Section {
                            AddItemEditorButton(
                                showAddItem: $showAddItem,
                                proxy: geometryProxy
                            )
                            .id(bottomID)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .overlay {
                    if showAddItem {
                        AddItemView(
                            viewModel: viewModel,
                            validator: validator,
                            cart: cart,
                            proxy: geometryProxy,
                            showAddItem: $showAddItem
                        )
                    }
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
                .navigationBarTitleDisplayMode(.inline)
                .scrollContentBackground(.hidden)
                .toolbar {
                    if !isEditActive {
                        ToolbarTitleMenu {
                            Button("Edit Details", systemImage: "pencil") {
                                showEditCart = true
                                navModel.cartToEdit = cart
                            }
                            Button("Delete Cart", systemImage: "trash", role: .destructive) {
                                withAnimation {
                                    deleteCart(cart)
                                }
                            }
                        }
                    }
                    toolbarContent()
                }
                .environment(\.editMode, .constant(isEditActive ? EditMode.active : EditMode.inactive))
                .sheet(isPresented: $showItemInfo) {
                    if let selection = navModel.itemToDescribe {
                        EditItemView(
                            viewModel: viewModel,
                            validator: validator,
                            cart: cart,
                            item: selection
                        )
                    }
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            if isEditActive {
                ConfirmToolbarButton {
                    withAnimation {
                        isEditActive = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            } else {
                Button("Edit") {
                    withAnimation {
                        isEditActive = true
                    }
                }
            }
        }
        if isEditActive {
            ToolbarItem(placement: .principal) {
                Text("\(navModel.selectedItems.count) selected")
                    .foregroundStyle(.accent)
            }
            ToolbarItem(placement: .secondaryAction) {
                Button(allSelected ? "Deselect All" : "Select All") {
                    if allSelected {
                        navModel.selectedItems = Set<CDItem.ID>()
                    } else {
                        itemList.forEach {
                            navModel.selectedItems.insert($0.id)
                        }
                    }
                }
                .disabled(totalItems == 0)
            }
            ToolbarItem(placement: .destructiveAction) {
                Button("Delete", systemImage: "trash") {
                    itemList.forEach { item in
                        if navModel.selectedItems.contains(item.id) {
                            withAnimation {
                                deleteItem(item)
                            }
                        }
                    }
                }
                .disabled(navModel.selectedItems.count == 0)
            }
        }
    }
    
//    private func deleteItem(at offsets: IndexSet) {
//        withAnimation {
//            offsets.map { itemList[$0] }.forEach(deleteItem)
//        }
//    }
    
    private func deleteItem(_ item: CDItem) {
        viewModel.objectWillChange.send()
        if navModel.selectedItems.contains(item.id) {
            navModel.selectedItems.remove(item.id)
        }
        viewContext.delete(item)
        
        do {
            try viewContext.save()
        } catch {
            if !item.isDeleted {
                logger.error("Failed to delete item. \(error.localizedDescription)")
            }
        }
        viewModel.update(context: viewContext)
    }
    
    private func deleteCart(_ cart: CDCart) {
        viewModel.objectWillChange.send()
        if navModel.selectedCarts.map(\.objectID).contains(cart.objectID) {
            navModel.selectedCarts.remove(cart)
        }
        viewContext.delete(cart)
        do {
            try viewContext.save()
        } catch {
            if !cart.isDeleted {
                logger.error("Failed to delete cart. \(error.localizedDescription)")
            }
        }
        viewModel.update(context: viewContext)
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
        ChecklistView(
            cart: cart!,
            showEditCart: .constant(false),
            viewModel: .preview,
            navModel: NavigationModel(),
            validator: ValidatorModel()
        )
    }
    .environment(\.managedObjectContext, viewContext)
}

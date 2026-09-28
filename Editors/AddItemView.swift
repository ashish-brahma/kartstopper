//
//  AddItemView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  A SwiftUI view that adds a new item.

import SwiftUI
import CoreData
internal import OSLog

struct AddItemView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var name: String
    @Binding var price: Double?
    let cart: CDCart
    
    let logger = PersistenceController.shared.logger
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    private enum Field: Hashable {
        case name
        case price
    }
    @FocusState private var focusedField: Field?
    
    @State private var isValidInput: Bool = true
    @State private var validationMessage: String = ""
    @State private var borderColor: Color = Color.clear
    
    private var totalItems: Int {
        CDCart.getTotalItems(for: cart, context: viewContext)
    }
    
    var body: some View {
        HStack {
            Label("Checkcircle", systemImage: "circle")
                .imageScale(.large)
                .labelStyle(.iconOnly)
                .foregroundStyle(Color.accentColor)
                .padding(.trailing, Design.Padding.trailing)
            
            VStack {
                TextField("Item Name", text: $name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .name)
                    .foregroundStyle(isValidInput ? Color.primary : Color.red)
                    .border(borderColor)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .price
                    }
                Divider()
                TextField("Price",
                          value: $price,
                          format: .currency(code: locale.currency?.identifier ?? "USD"))
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .price)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                CancelToolbarButton {
                    reset()
                    focusedField = nil
                }
                Spacer()
                ConfirmToolbarButton {
                    validateItem()
                    if isValidInput {
                        addItem()
                        reset()
                    }
                    focusedField = .name
                }
            }
            ToolbarItem(placement: .principal) {
                Text("\(validationMessage)")
                    .foregroundStyle(Color.accentColor)
            }
        }
        .onAppear {
            name = ""
            price = nil
            if totalItems == 0 {
                focusedField = .name
            }
        }
        .onChange(of: name) { newName in
            isValidInput = true
            validationMessage = ""
            borderColor = Color.clear
        }
    }
    
    private func saveContext(item: CDItem) {
        do {
            try viewContext.save()
        } catch {
            if !item.isInserted {
                logger.error("Failed to insert new item.\(error.localizedDescription)")
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = CDItem(context: viewContext)
            newItem.id = Int32(totalItems + 1)
            newItem.name = name
            newItem.timestamp = Date()
            newItem.price = price ?? 0.00
            newItem.cart = cart
            saveContext(item: newItem)
            viewModel.update(context: viewContext)
        }
    }
    
    private func validateItem() {
        let existingItems = CDItem.getItems(by: name,
                                            context: viewContext)
        
        isValidInput = !name.isEmpty && existingItems.count == 0
        
        if !isValidInput {
            if name.isEmpty {
                validationMessage = "Enter a valid name."
                borderColor = Color.red
            } else if existingItems.count != 0 {
                validationMessage = "Item aleardy exists."
            }
        }
    }
    
    private func reset() {
        name = ""
        price = nil
        validationMessage = ""
        borderColor = Color.clear
    }
}

#Preview {
    AddItemView(viewModel: .preview,
                name: .constant(CDItem.preview.displayName),
                price: .constant(CDItem.preview.price),
                cart: .preview)
    .environment(\.locale, Locale(identifier: "en-IN"))
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

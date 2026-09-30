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
    var cart: CDCart
    
    let logger = PersistenceController.shared.logger
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    private enum Field: Hashable {
        case name
        case price
    }
    @FocusState private var focusedField: Field?
    
    @State private var name: String = ""
    @State private var price: Double?
    @State private var isValidInput = true
    @State private var showValidationMessage = false
    
    private var totalItems: Int {
        CDCart.getTotalItems(for: cart, context: viewContext)
    }
    
    var body: some View {
        Section {
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
                            focusedField = .name
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
            
        } header: {
            if showValidationMessage {
                Text("Item already exists.")
                    .foregroundStyle(Color.red)
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
            showValidationMessage = false
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            logger.error("Failed to insert new item.\(error.localizedDescription)")
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
            saveContext()
            viewModel.update(context: viewContext)
        }
    }
    
    private func validateItem() {
        let existingItemCount = CDItem.findItems(by: name,
                                                 context: viewContext)
        
        isValidInput = !name.isEmpty && existingItemCount == 0
        
        if existingItemCount != 0 {
            showValidationMessage = true
        }
    }
    
    private func reset() {
        name = ""
        price = nil
        showValidationMessage = false
    }
}

#Preview {
    AddItemView(viewModel: .preview,
                cart: .preview)
    .environment(\.locale, Locale(identifier: "en-IN"))
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

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
    var proxy: GeometryProxy
    
    let logger = PersistenceController.shared.logger
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
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
                Spacer()
                VStack(alignment: .center) {
                    cell()
                    
                    if !name.isEmpty {
                        addButton()
                    }
                }
                .frame(maxWidth: horizontalSizeClass == .regular ?  Design.addItemMaxWidth : proxy.size.width)
                Spacer()
            }
            .padding(.bottom, Design.Padding.bottom * 2)
        } header: {
            if showValidationMessage {
                Text("Item already exists.")
                    .foregroundStyle(Color.red)
            }
        }
        .listRowBackground(Color.clear)
        .onChange(of: name) { newName in
            isValidInput = true
            showValidationMessage = false
        }
    }
    
    private func addButton() -> some View {
        Button {
            validateItem()
            if isValidInput {
                addItem()
                reset()
                focusedField = .name
            }
        } label: {
            Label("Add Item", systemImage: "plus")
                .foregroundStyle(colorScheme == .dark ? .black : .white)
                .frame(width: Design.addItemMaxWidth/1.6)
        }
        .tint(Color.accent)
        .buttonStyle(.borderedProminent)
    }
    
    @ViewBuilder
    private func cell() -> some View {
        HStack {
            Label("Checkcircle", systemImage: "circle")
                .imageScale(.large)
                .labelStyle(.iconOnly)
                .foregroundStyle(Color.accentColor)
                .padding(.trailing, Design.Padding.trailing)
            
            VStack(alignment: .leading) {
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
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    CancelToolbarButton {
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
        }
        .padding(Design.Padding.standard)
        .background {
            RoundedRectangle(cornerRadius: Design.cornerRadius)
                .fill(Color(.tertiarySystemFill))
        }
        .onAppear {
            if totalItems == 0 {
                focusedField = .name
            }
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
    GeometryReader { proxy in
        List {
            AddItemView(viewModel: .preview,
                        cart: .preview,
                        proxy: proxy
            )
        }
        .environment(\.locale, Locale(identifier: "en-IN"))
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
    }
}

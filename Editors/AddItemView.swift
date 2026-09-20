//
//  AddItemView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  A SwiftUI view that adds a new item.

import SwiftUI
import CoreData

struct AddItemView: View {
    @Binding var name: String
    @Binding var price: Double?
    let cart: CDCart
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    
    private enum Field: Hashable {
        case name
        case price
    }
    @FocusState private var focusedField: Field?
    
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
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .price
                    }
                Divider()
                TextField("Price",
                          value: $price,
                          format: .currency(code: locale.currency?.identifier ?? "USD"))
                .keyboardType(.numbersAndPunctuation)
                .focused($focusedField, equals: .price)
                .submitLabel(.done)
                .onSubmit {
                    if !name.isEmpty && price != nil {
                        addItem(to: cart)
                        name = ""
                        price = nil
                        focusedField = .name
                    } else {
                        focusedField = nil
                    }
                }
            }
        }
        .onAppear {
            name = ""
            price = nil
            if totalItems == 0 {
                focusedField = .name
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
    
    private func addItem(to cart: CDCart) {
        withAnimation {
            let newItem = CDItem(context: viewContext)
            newItem.id = Int32(totalItems + 1)
            newItem.name = name
            newItem.timestamp = Date()
            newItem.price = price ?? 0.00
            newItem.cart = cart
            saveContext()
        }
    }
}

#Preview {
    AddItemView(name: .constant(CDItem.preview.displayName),
                price: .constant(CDItem.preview.price),
                cart: .preview)
    .environment(\.locale, Locale(identifier: "en-IN"))
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

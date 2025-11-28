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
    let cart: CDCart
    
    @ObservedObject var viewModel = ViewModel()
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    
    @State private var name = ""
    @State private var notes = ""
    @State private var price: Double = 0.00
    
    private var totalItems: Int {
        CDCart.getTotalItems(for: cart, context: viewContext)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Item Name")) {
                Group {
                    TextField("Enter a name for the item", text: $name)
                }
            }
            
            Section(header: Text("Price")) {
                Group {
                    TextField("Price",
                              value: $price,
                              format: .currency(code: locale.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
                }
            }
            
            Section(header: Text("Item Description")) {
                Group {
                    TextField("Add notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(Design.descriptionFieldLineLimit)
                        .frame(height: Design.descriptionFieldHeight, alignment: .top)
                }
            }
        }
        .navigationTitle("Add Item")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    addItem(to: cart)
                    viewModel.itemQuery = ""
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
    }
    
    private func addItem(to cart: CDCart) {
        withAnimation {
            let newItem = CDItem(context: viewContext)
            newItem.id = Int32(totalItems + 1)
            newItem.name = name
            newItem.timestamp = Date()
            newItem.price = price
            newItem.notes = notes
            newItem.cart = cart
            saveContext()
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
}

#Preview {
    NavigationStack {
        AddItemView(cart: .preview)
    }
    .environment(\.locale, Locale(identifier: "en-IN"))
}

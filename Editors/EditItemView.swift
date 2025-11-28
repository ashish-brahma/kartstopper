//
//  EditItemView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 05/11/25.
//

import SwiftUI
import CoreData

struct EditItemView: View {
    var item: CDItem
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    
    @State private var name = ""
    @State private var notes = ""
    @State private var price: Double = 0.00
    
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
                        .frame(height:Design.descriptionFieldHeight, alignment: .top)
                }
            }
        }
        .navigationTitle(item.displayName)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Dismiss") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Edit Item Details")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    updateItem()
                    dismiss()
                }
            }
        }
        .onAppear {
            name = item.name ?? ""
            notes = item.notes ?? ""
            price = item.price
        }
    }
    
    private func updateItem() {
        withAnimation {
            if !name.isEmpty {
                item.name = name
            }
            
            if !notes.isEmpty {
                item.notes = notes
            }
            
            if price != 0.0 {
                item.price = price
            }
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
    EditItemView(item: .preview)
}

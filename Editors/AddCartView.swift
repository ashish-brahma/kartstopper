//
//  AddCartView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  A SwiftUI view that adds a new cart.

import SwiftUI
import CoreData

struct AddCartView: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var notes = ""
    
    var body: some View {
        Form {
            Section(header: Text("Cart Name")) {
                Group {
                    TextField("Enter a name for the cart", text: $name)
                }
            }
            
            Section(header: Text("Cart Description")) {
                Group {
                    TextField("Add notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(Design.descriptionFieldLineLimit)
                        .frame(height: Design.descriptionFieldHeight, alignment: .top)
                }
            }
        }
        .navigationTitle("Add Cart")
        .scrollContentBackground(.hidden)
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    addCart()
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
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
        AddCartView(viewModel: .preview)
    }
}

//
//  EditCartView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 05/11/25.
//

import SwiftUI
import CoreData

struct EditCartView: View {
    var cart: CDCart
    
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
        .navigationTitle(cart.displayName)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Dismiss") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Edit Cart Details")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    updateCart()
                    dismiss()
                }
            }
        }
        .onAppear {
            name = cart.name ?? ""
            notes = cart.notes ?? ""
        }
    }
    
    private func updateCart() {
        withAnimation {
            if !name.isEmpty {
                cart.name = name
            }
            
            if !notes.isEmpty {
                cart.notes = notes
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
    EditCartView(cart: .preview)
}

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
            Section(header: Text("Created On")) {
                Text(cart.displayDate.formatted(date: .abbreviated,
                                                time: .shortened))
                .foregroundStyle(.secondary)
                .listRowBackground(Color.gray.opacity(0.2))
            }
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
        .scrollContentBackground(.hidden)
        .background(Color.background)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Label("Cancel", systemImage: "xmark")
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Edit Cart Details")
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    updateCart()
                    dismiss()
                } label: {
                    Label("Done", systemImage: "checkmark")
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
    NavigationStack {
        EditCartView(cart: .preview)
    }
}

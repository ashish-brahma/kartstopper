//
//  EditCartView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 05/11/25.
//
//  A SwiftUI view that edits an existing cart's data.

import SwiftUI
import CoreData

struct EditCartView: View {
    var cart: CDCart
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var notes = ""
    
    private enum Field: Hashable {
        case name
        case notes
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationStack {
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
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .notes
                            }
                    }
                }
                
                Section(header: Text("Cart Description")) {
                    Group {
                        TextField("Add notes (optional)", text: $notes, axis: .vertical)
                            .textInputAutocapitalization(.sentences)
                            .lineLimit(Design.descriptionFieldLineLimit)
                            .frame(height: Design.descriptionFieldHeight, alignment: .top)
                            .focused($focusedField, equals: .notes)
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
        }
        .onAppear {
            name = cart.name ?? ""
            notes = cart.notes ?? ""
            focusedField = .name
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

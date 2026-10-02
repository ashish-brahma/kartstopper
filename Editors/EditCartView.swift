//
//  EditCartView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 05/11/25.
//
//  A SwiftUI view that edits an existing cart's data.

import SwiftUI
import CoreData
internal import OSLog

struct EditCartView: View {
    @ObservedObject var viewModel: ViewModel
    var cart: CDCart
    
    let logger = PersistenceController.shared.logger
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var notes = ""
    
    private enum Field: Hashable {
        case name
        case notes
    }
    @FocusState private var focusedField: Field?
    
    @State private var isValidInput = true
    @State private var showValidationMessage = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Created On")) {
                    Text(cart.displayDate.formatted(date: .abbreviated,
                                                    time: .shortened))
                    .foregroundStyle(.secondary)
                }
                .listRowBackground(Color(.tertiarySystemFill))
                
                Section {
                    Group {
                        TextField("Enter a name for the cart", text: $name)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .focused($focusedField, equals: .name)
                            .foregroundStyle(isValidInput ? Color.primary : Color.red)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .notes
                            }
                    }
                } header: {
                    Text("Cart Name")
                } footer: {
                    if showValidationMessage {
                        Text("Cart already exists.")
                            .foregroundStyle(Color.red)
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
                    CancelToolbarButton { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit Cart Details")
                }
                ToolbarItem(placement: .confirmationAction) {
                    ConfirmToolbarButton {
                        validateCart()
                        if isValidInput {
                            updateCart()
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            name = cart.name ?? ""
            notes = cart.notes ?? ""
            focusedField = .name
        }
        .onChange(of: name) { newName in
            isValidInput = true
            showValidationMessage = false
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
            viewModel.update(context: viewContext)
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            logger.error("Failed to update cart. \(error.localizedDescription)")
        }
    }
    
    private func validateCart() {
        if name == cart.displayName { return }
        
        let existingCartCount = CDCart.findCarts(by: name,
                                                 context: viewContext)
        
        isValidInput = !name.isEmpty && existingCartCount == 0
        
        if existingCartCount != 0 {
            showValidationMessage = true
        }
    }
}

#Preview {
    EditCartView(viewModel: .preview,
                 cart: .preview)
}

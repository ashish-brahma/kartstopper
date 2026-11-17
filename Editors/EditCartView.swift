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
    @ObservedObject var validator: ValidatorModel
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
    
    private var isValidName: Bool {
        switch validator.error {
        case .nameIsEmpty, .containsInvalidCharacters, .cartExists(editorKind: .edit):
            false
        default:
            true
        }
    }
    
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
                            .foregroundStyle(isValidName ? Color.primary : Color.red)
                            .submitLabel(.next)
                            .onSubmit {
                                validateInput()
                                focusedField = .notes
                            }
                    }
                } header: {
                    Text("Cart Name")
                } footer: {
                    if !isValidName {
                        if let error = validator.error {
                            Text("\(error.message)")
                                .foregroundStyle(Color.red)
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
                    CancelToolbarButton { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    Text("Edit Cart Details")
                }
                ToolbarItem(placement: .confirmationAction) {
                    ConfirmToolbarButton {
                        validateInput()
                        if validator.error == nil {
                            updateCart()
                            validator.reset()
                            dismiss()
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .onAppear {
            name = cart.name ?? ""
            notes = cart.notes ?? ""
            focusedField = .name
            validator.reset()
        }
        .onChange(of: name) { _ in
            validator.error = nil
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
            let logger = PersistenceController.shared.logger
            logger.error("Failed to update cart. \(error.localizedDescription)")
        }
    }
    
    private func validateInput() {
        if name == cart.displayName { return }
        
        do {
            validator.cartName = name
            try validator.validateCart(
                editorKind: .edit,
                context: viewContext
            )
        } catch {
            if let err = error as? ValidationError {
                validator.error = err
            } else {
                let logger = validator.logger
                logger.error("Failed to validate cart.\(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    EditCartView(viewModel: .preview,
                 validator: ValidatorModel(),
                 cart: .preview)
}

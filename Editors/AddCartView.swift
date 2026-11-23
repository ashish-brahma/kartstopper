//
//  AddCartView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  A SwiftUI view that adds a new cart.

import SwiftUI
import CoreData
internal import OSLog

struct AddCartView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var validator: ValidatorModel
    
    @Binding var showAddCart: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private enum Field: Hashable {
        case name
        case notes
    }
    @FocusState private var focusedField: Field?
    
    @State private var name = ""
    @State private var notes = ""
    
    private var isValidName: Bool {
        switch validator.error {
        case .nameIsEmpty, .containsInvalidCharacters, .cartExists(editorKind: .add):
            false
        default:
            true
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        TextField("Enter a name for the cart", text: $name)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .focused($focusedField, equals: .name)
                            .foregroundStyle(isValidName ? Color.primary : Color.red)
                            .submitLabel(.next)
                            .onSubmit {
                                validateInput()
                                if isValidName {
                                    focusedField = .notes
                                }
                            }
                        
                        if focusedField == .name && !name.isEmpty {
                            ClearButton {
                                name = ""
                            }
                        }
                    }
                } header: {
                    Text("Cart Name")
                } footer: {
                    if let error = validator.error {
                        Text("\(error.message)")
                            .foregroundStyle(Color.red)
                            .font(.callout)
                    }
                }
                
                Section(header: Text("Cart Description")) {
                    HStack(alignment: .top) {
                        TextField("Add notes (optional)",
                                  text: $notes,
                                  axis: .vertical)
                        .textInputAutocapitalization(.sentences)
                        .frame(height: Design.descriptionFieldHeight,
                               alignment: .top)
                        .lineLimit(Design.descriptionFieldLineLimit)
                        .focused($focusedField, equals: .notes)
                        
                        if focusedField == .notes && !notes.isEmpty {
                            ClearButton {
                                notes = ""
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add New Cart")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Color.background)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    CancelToolbarButton {
                        showAddCart = false
                        focusedField = nil
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    ConfirmToolbarButton(action: submitAction)
                        .disabled(name.isEmpty)
                }
            }
            .onChange(of: name) { _ in
                validator.error = nil
            }
            .onChange(of: focusedField) { newField in
                if newField != .name {
                    validateInput()
                } else {
                    validator.error = nil
                }
            }
            .onAppear {
                reset()
                focusedField = .name
            }
        }
    }
    
    private func submitAction() {
        validateInput()
        if validator.error == nil {
            addCart()
            reset()
            showAddCart = false
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let logger = PersistenceController.shared.logger
            logger.error("Failed to insert new cart. \(error.localizedDescription)")
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
    
    private func validateInput() {
        do {
            validator.cartName = name
            try validator.validateCart(
                editorKind: .add,
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
    
    private func reset() {
        name = ""
        notes = ""
        validator.reset()
    }
}

#Preview {
    NavigationSplitView {
        Section {
            Text("Cart")
        }
    } detail: {
        Text("Cart Detail")
    }
    .navigationTitle("Cart Title")
    .sheet(isPresented: .constant(true)) {
        AddCartView(
            viewModel: .preview,
            validator: ValidatorModel(),
            showAddCart: .constant(true)
        )
    }
}

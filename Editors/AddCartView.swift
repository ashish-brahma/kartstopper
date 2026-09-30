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
    
    @Binding var showAddCart: Bool
    
    let logger = PersistenceController.shared.logger
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private enum Field: Hashable {
        case name
        case notes
    }
    @FocusState private var focusedField: Field?
    
    @State private var name = ""
    @State private var notes = ""
    @State private var isValidInput = true
    @State private var showValidationMessage = false
    
    var body: some View {
        Section {
            VStack {
                TextField("Cart Name", text: $name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .name)
                    .foregroundStyle(isValidInput ? Color.primary : Color.red)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .notes
                    }
                Divider()
                TextField("Add notes (optional)",
                          text: $notes,
                          axis: .vertical)
                .textInputAutocapitalization(.sentences)
                .frame(height: Design.descriptionFieldHeight,
                       alignment: .top)
                .lineLimit(Design.descriptionFieldLineLimit)
                .focused($focusedField, equals: .notes)
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    CancelToolbarButton {
                        reset()
                        showAddCart = false
                    }
                    Spacer()
                    ConfirmToolbarButton {
                        validateCart()
                        if isValidInput {
                            addCart()
                            reset()
                            showAddCart = false
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        } header: {
            if showValidationMessage {
                Text("Cart already exists.")
                    .foregroundStyle(Color.red)
            }
        }
        .onAppear {
            name = ""
            notes = ""
            focusedField = .name
        }
        .onChange(of: name) { newName in
            isValidInput = true
            showValidationMessage = false
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
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
    
    private func validateCart() {
        let existingCartCount = CDCart.findCarts(by: name,
                                                 context: viewContext)
        
        isValidInput = !name.isEmpty && existingCartCount == 0
        
        if existingCartCount != 0 {
            showValidationMessage = true
        }
    }
    
    private func reset() {
        name = ""
        notes = ""
        showValidationMessage = false
    }
}

#Preview {
    NavigationStack {
        AddCartView(viewModel: .preview,
                    showAddCart: .constant(true))
    }
}

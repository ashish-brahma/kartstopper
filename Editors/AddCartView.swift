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
    let proxy: GeometryProxy
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    private enum Field: Hashable {
        case name
        case notes
    }
    @FocusState private var focusedField: Field?
    
    @State private var name = ""
    @State private var notes = ""
    
    private var addButtonTextColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    private var isValidName: Bool {
        switch validator.error {
        case .nameIsEmpty, .containsInvalidCharacters, .cartExists:
            false
        default:
            true
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(alignment: .center) {
                    cell()
                    
                    if let message = validator.error?.message  {
                        Text("\(message)")
                            .foregroundStyle(Color.red)
                            .font(.callout)
                    }
                    
                    buttonToolbar()
                }
                .frame(maxWidth: horizontalSizeClass == .regular ?  Design.addCartMaxWidth : proxy.size.width/1.2)
                
                Spacer()
            }
            .padding(Design.Padding.standard * 2)
            .padding(.bottom, Design.Padding.bottom * 4)
            .background {
                if colorScheme == .light {
                    Rectangle()
                        .fill(Material.thick)
                } else {
                    Rectangle()
                        .fill(Color(.systemGroupedBackground))
                }
            }
            
            Spacer()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                CancelToolbarButton {
                    focusedField = nil
                }
                Spacer()
                ConfirmToolbarButton(action: submitAction)
                    .disabled(name.isEmpty)
            }
        }
        .onChange(of: name) { _ in
            validator.error = nil
        }
        .onAppear {
            reset()
            focusedField = .name
        }
    }
    
    @ViewBuilder
    private func cell() -> some View {
        VStack(alignment: .leading) {
            TextField("Cart Name", text: $name)
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
        .padding(Design.Padding.standard)
        .background {
            RoundedRectangle(cornerRadius: Design.cornerRadius)
                .fill(Color(.secondarySystemGroupedBackground))
        }
        
    }
    
    @ViewBuilder
    private func buttonToolbar() -> some View {
        HStack {
            CancelToolbarButton {
                showAddCart = false
                focusedField = nil
            }
            .tint(Color.foreground)
            .buttonStyle(.bordered)
            
            Spacer()
            
            AddToolbarButton(entityName: "Cart",
                             action: submitAction)
                .foregroundStyle(name.isEmpty ? Color.secondary : addButtonTextColor)
                .disabled(name.isEmpty)
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
    GeometryReader { proxy in
        NavigationSplitView {
            Section {
                Text("Cart")
            }
        } detail: {
            Text("Cart Detail")
        }
        .navigationTitle("Cart Title")
        .overlay {
            AddCartView(
                viewModel: .preview,
                validator: ValidatorModel(),
                showAddCart: .constant(true),
                proxy: proxy
            )
        }
    }
}

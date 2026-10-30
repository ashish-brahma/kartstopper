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
    let proxy: GeometryProxy
    
    let logger = PersistenceController.shared.logger
    
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
    @State private var isValidInput = true
    @State private var showValidationMessage = false
    
    private var addButtonTextColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(alignment: .center) {
                    cell()
                    
                    if showValidationMessage {
                        Text("Cart already exists.")
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
    
    @ViewBuilder
    private func cell() -> some View {
        VStack(alignment: .leading) {
            TextField("Cart Name", text: $name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .focused($focusedField, equals: .name)
                .foregroundStyle(isValidInput ? Color.primary : Color.red)
                .submitLabel(.next)
                .onSubmit {
                    validateCart()
                    if isValidInput {
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
                .tint(name.isEmpty ? Color.secondary.opacity(0.7) : Color.accent)
        }
    }
    
    private func submitAction() {
        validateCart()
        if isValidInput {
            addCart()
            reset()
            showAddCart = false
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
                showAddCart: .constant(true),
                proxy: proxy
            )
        }
    }
}

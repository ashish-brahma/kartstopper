//
//  AddItemView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  A SwiftUI view that adds a new item.

import SwiftUI
import CoreData
internal import OSLog

struct AddItemView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var validator: ValidatorModel
    var cart: CDCart
    let proxy: GeometryProxy
    @Binding var showAddItem: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.locale) private var locale
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    
    private enum Field: Hashable {
        case name
        case price
    }
    @FocusState private var focusedField: Field?
    
    @State private var name: String = ""
    @State private var price: Double?
    
    private var totalItems: Int {
        CDCart.getTotalItems(for: cart, context: viewContext)
    }
    
    private var addButtonTextColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    private var isValidName: Bool {
        switch validator.error {
        case .nameIsEmpty, .containsInvalidCharacters, .itemExists(editorKind: .add):
            false
        default:
            true
        }
    }
    
    private var currencyCode: String {
        locale.currency?.identifier ?? "USD"
    }
    
    // MARK: - Views
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                VStack(alignment: .center) {
                    cell()
                    
                    if let error = validator.error {
                        Text("\(error.message)")
                            .foregroundStyle(Color.red)
                            .font(.callout)
                    }
                    
                    buttonToolbar()
                }
                .frame(maxWidth: horizontalSizeClass == .regular ?  Design.addItemMaxWidth : proxy.size.width/1.2)
                
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
    
    @ViewBuilder
    private func buttonToolbar() -> some View {
        VStack {
            Button(action: submitAction) {
                Label("Add Item", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .foregroundStyle(name.isEmpty ? Color.secondary : addButtonTextColor)
            .tint(name.isEmpty ? Color.secondary.opacity(0.7) : Color.accent)
            .disabled(name.isEmpty)
            .padding(.bottom, Design.Padding.bottom)
            
            Button {
                showAddItem = false
                focusedField = nil
            } label: {
                Label("Cancel", systemImage: "xmark")
                    .frame(maxWidth: .infinity)
            }
            .tint(Color.foreground)
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    @ViewBuilder
    private func cell() -> some View {
        HStack {
            Label("Checkcircle", systemImage: "circle")
                .imageScale(.large)
                .labelStyle(.iconOnly)
                .foregroundStyle(Color.accentColor)
                .padding(.trailing, Design.Padding.trailing)
            
            VStack(alignment: .leading) {
                HStack {
                    TextField("Item Name", text: $name)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .name)
                        .foregroundStyle(isValidName ? Color.primary : Color.red)
                        .submitLabel(.next)
                        .onSubmit {
                            validateInput()
                            if isValidName {
                                focusedField = .price
                            }
                        }
                    
                    if focusedField == .name && !name.isEmpty {
                        ClearButton {
                            name = ""
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    TextField("Price (\(currencyCode))",
                              value: $price,
                              format: .currency(code: currencyCode))
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
                    .submitLabel(.done)
                    .onSubmit {
                        submitAction()
                    }
                    
                    if focusedField == .price && price != nil {
                        ClearButton {
                            price = nil
                        }
                    }
                }
            }
        }
        .padding(Design.Padding.standard)
        .background {
            RoundedRectangle(cornerRadius: Design.cornerRadius)
                .fill(Color(.secondarySystemGroupedBackground))
        }
    }
    
    // MARK: - Methods
    
    private func submitAction() {
        validateInput()
        if validator.error == nil {
            addItem()
            reset()
            focusedField = .name
            showAddItem = false
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let logger = PersistenceController.shared.logger
            logger.error("Failed to insert new item.\(error.localizedDescription)")
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = CDItem(context: viewContext)
            newItem.id = Int32(totalItems + 1)
            newItem.name = name
            newItem.timestamp = Date()
            newItem.price = price ?? 0.00
            newItem.cart = cart
            saveContext()
            viewModel.update(context: viewContext)
        }
    }
    
    private func validateInput() {
        do {
            validator.itemName = name
            validator.cartName = cart.displayName
            try validator.validateItem(
                editorKind: .add,
                context: viewContext
            )
        } catch {
            if let err = error as? ValidationError {
                validator.error = err
            } else {
                let logger = validator.logger
                logger.error("Failed to validate item.\(error.localizedDescription)")
            }
        }
    }
    
    private func reset() {
        name = ""
        price = nil
        validator.reset()
    }
}

#Preview {
    GeometryReader { proxy in
        NavigationStack {
            List {
                Section {
                    Text("Item")
                }
            }
            .navigationTitle("Cart Title")
            .overlay {
                AddItemView(
                    viewModel: .preview,
                    validator: ValidatorModel(),
                    cart: .preview,
                    proxy: proxy,
                    showAddItem: .constant(true)
                )
            }
            .environment(\.locale, Locale(identifier: "en-IN"))
            .environment(\.managedObjectContext,
                          PersistenceController.preview.container.viewContext)
        }
    }
}

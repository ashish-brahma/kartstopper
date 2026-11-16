//
//  EditItemView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 05/11/25.
//
//  A SwiftUI view that edits an existing item's data.

import SwiftUI
import CoreData
internal import OSLog

struct EditItemView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var validator: ValidatorModel
    var cart: CDCart
    var item: CDItem
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    
    @State private var name = ""
    @State private var notes = ""
    @State private var price: Double = 0.00
    
    private enum Field: Hashable {
        case name
        case price
        case notes
    }
    @FocusState private var focusedField: Field?
    
    private var isValidName: Bool {
        switch validator.error {
        case .nameIsEmpty, .containsInvalidCharacters:
            false
        default:
            true
        }
    }
    
    private var currencyCode: String {
        locale.currency?.identifier ?? "USD"
    }
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                Form {
                    Section {
                        if item.imageURL != nil {
                            displayImage(proxy: proxy)
                        } else {
                            placeholderImage(proxy: proxy)
                        }
                    }
                    .listRowBackground(Color.clear)
                    
                    Section(header: Text("Created On")) {
                        Text(item.displayDate.formatted(date: .abbreviated,
                                                        time: .shortened))
                        .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color(.tertiarySystemFill))
                    
                    Section {
                        TextField("Enter a name for the item", text: $name)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .focused($focusedField, equals: .name)
                            .foregroundStyle(isValidName ? Color.primary : Color.red)
                            .submitLabel(.next)
                            .onSubmit {
                                validateInput()
                                focusedField = .price
                            }
                    } header: {
                        Text("Item Name")
                    } footer: {
                        if let error = validator.error {
                            if error == .itemExists {
                                Text("Name remains unchanged.")
                                    .foregroundStyle(Color.info)
                            } else if !isValidName {
                                Text(error.message)
                                    .foregroundStyle(Color.red)
                            }
                        }
                    }
                    
                    Section(header: Text("Price")) {
                        TextField("Enter price (\(currencyCode))",
                                  value: $price,
                                  format: .currency(code: currencyCode))
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .price)
                    }
                    
                    Section(header: Text("Item Description")) {
                        TextField("Add notes (optional)", text: $notes, axis: .vertical)
                            .lineLimit(Design.descriptionFieldLineLimit)
                            .frame(height:Design.descriptionFieldHeight, alignment: .top)
                            .focused($focusedField, equals: .notes)
                    }
                }
                .navigationTitle(item.displayName)
                .scrollContentBackground(.hidden)
                .background(Color.background)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        CancelToolbarButton { dismiss() }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Edit Item Details")
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        ConfirmToolbarButton {
                            validateInput()
                            if validator.error == nil {
                                updateItem()
                                validator.reset()
                                dismiss()
                            }
                        }
                        .disabled(name.isEmpty)
                    }
                    if focusedField == .price {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Next") {
                                focusedField = .notes
                            }
                        }
                    }
                }
            }
            .onAppear {
                name = item.name ?? ""
                notes = item.notes ?? ""
                price = item.price
                focusedField = .name
                validator.reset()
            }
            .onChange(of: name) { _ in
                validator.error = nil
            }
        }
    }
    
    private func displayImage(proxy: GeometryProxy) -> some View {
        AsyncImage(url: item.imageURL) { image in
            image
                .resizable()
                .clipShape(.rect(cornerRadius: Design.avatarDetailCornerRadius))
        } placeholder: {
            ProgressView()
        }
        .frame(width: proxy.size.width/1.11,
               height: proxy.size.height/2)
    }
    
    private func placeholderImage(proxy: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: Design.avatarDetailCornerRadius)
            .fill(item.itemColor)
            .overlay {
                if !name.isEmpty {
                    Text(String(name.first!))
                        .font(.system(size: Design.avatarDetailTextFontSize))
                }
            }
            .frame(width: proxy.size.width/1.11,
                   height: proxy.size.height/2)
    }
    
    private func updateItem() {
        withAnimation {
            if !name.isEmpty {
                item.name = name
            }
            
            if !notes.isEmpty {
                item.notes = notes
            }
            
            if price != 0.0 {
                item.price = price
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
            logger.error("Failed to update item. \(error.localizedDescription)")
        }
    }
    
    private func validateInput() {
        if name == item.displayName { return }
        
        do {
            validator.itemName = name
            validator.cartName = cart.displayName
            try validator.validateItem(context: viewContext)
        } catch {
            if let err = error as? ValidationError {
                validator.error = err
            } else {
                let logger = validator.logger
                logger.error("Failed to validate item.\(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    EditItemView(viewModel: .preview,
                 validator: ValidatorModel(),
                 cart: .preview,
                 item: .preview)
}

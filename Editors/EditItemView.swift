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
    var item: CDItem
    
    let logger = PersistenceController.shared.logger
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    
    @State private var name = ""
    @State private var notes = ""
    @State private var price: Double = 0.00
    @State private var isValidInput = true
    @State private var showValidationMessage = false
    
    private enum Field: Hashable {
        case name
        case price
        case notes
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        GeometryReader { reader in
            NavigationStack {
                Form {
                    Section {
                        if item.imageURL != nil {
                            displayImage(reader: reader)
                        } else {
                            placeholderImage(reader: reader)
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
                            .foregroundStyle(isValidInput ? Color.primary : Color.red)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .price
                            }
                    } header: {
                        Text("Item Name")
                    } footer: {
                        if showValidationMessage {
                            Text("Item already exists.")
                                .foregroundStyle(Color.red)
                        }
                    }
                    
                    Section(header: Text("Price")) {
                        TextField("Price",
                                  value: $price,
                                  format: .currency(code: locale.currency?.identifier ?? "USD"))
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
                            validateItem()
                            if isValidInput {
                                updateItem()
                                dismiss()
                            }
                        }
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
            }
            .onChange(of: name) { newName in
                isValidInput = true
                showValidationMessage = false
            }
        }
    }
    
    private func displayImage(reader: GeometryProxy) -> some View {
        AsyncImage(url: item.imageURL) { image in
            image
                .resizable()
                .clipShape(.rect(cornerRadius: Design.avatarDetailCornerRadius))
        } placeholder: {
            ProgressView()
        }
        .frame(width: reader.size.width/1.11,
               height: reader.size.height/2)
    }
    
    private func placeholderImage(reader: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: Design.avatarDetailCornerRadius)
            .fill(item.itemColor)
            .overlay {
                if !name.isEmpty {
                    Text(String(name.first!))
                        .font(.system(size: Design.avatarDetailTextFontSize))
                }
            }
            .frame(width: reader.size.width/1.11,
                   height: reader.size.height/2)
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
            if !item.isUpdated {
                logger.error("Failed to update item. \(error.localizedDescription)")
            }
        }
    }
    
    private func validateItem() {
        if name == item.displayName { return }
        
        let existingItemCount = CDItem.findItems(by: name,
                                                 context: viewContext)
        
        isValidInput = !name.isEmpty && existingItemCount == 0
        
        if existingItemCount != 0 {
            showValidationMessage = true
        }
    }
}

#Preview {
    EditItemView(viewModel: .preview,
                 item: .preview)
}

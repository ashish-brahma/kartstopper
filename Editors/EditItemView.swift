//
//  EditItemView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 05/11/25.
//

import SwiftUI
import CoreData

struct EditItemView: View {
    var item: CDItem
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    
    @State private var name = ""
    @State private var notes = ""
    @State private var price: Double = 0.00
    @FocusState private var isEditing
    
    var body: some View {
        GeometryReader { reader in
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
                .listRowBackground(Color.gray.opacity(0.2))
                
                Section(header: Text("Item Name")) {
                    TextField("Enter a name for the item", text: $name)
                        .focused($isEditing)
                }
                
                Section(header: Text("Price")) {
                    TextField("Price",
                              value: $price,
                              format: .currency(code: locale.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Item Description")) {
                    TextField("Add notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(Design.descriptionFieldLineLimit)
                        .frame(height:Design.descriptionFieldHeight, alignment: .top)
                }
            }
            .navigationTitle(item.displayName)
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
                    Text("Edit Item Details")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        updateItem()
                        dismiss()
                    } label: {
                        Label("Done", systemImage: "checkmark")
                    }
                }
            }
            .onAppear {
                name = item.name ?? ""
                notes = item.notes ?? ""
                price = item.price
                isEditing = true
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
    NavigationStack {
        EditItemView(item: .preview)
    }
}

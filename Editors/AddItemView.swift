//
//  AddItemView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  A SwiftUI view that adds a new item.

import SwiftUI

struct AddItemView: View {
    @Binding var name: String
    @Binding var price: Double?
    let addAction: () -> Void
    let onDismiss: () -> Void
    
    @Environment(\.locale) private var locale
    @FocusState private var isAddingPrice
    
    var body: some View {
        HStack {
            Label("Checkcircle", systemImage: "circle")
                .imageScale(.large)
                .labelStyle(.iconOnly)
                .foregroundStyle(Color.accentColor)
                .padding(.trailing, Design.Padding.trailing)
            
            VStack {
                TextField("Item Name",
                          text: $name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .onSubmit {
                        isAddingPrice = true
                    }
                Divider()
                TextField("Price",
                          value: $price,
                          format: .currency(code: locale.currency?.identifier ?? "USD"))
                .focused($isAddingPrice)
                .keyboardType(.numbersAndPunctuation)
                .submitLabel(.done)
                .onSubmit {
                    if !name.isEmpty && price != nil {
                        addAction()
                        name = ""
                        price = nil
                    }
                    onDismiss()
                }
            }
        }
        .onAppear {
            name = ""
            price = nil
        }
    }
}

#Preview {
    AddItemView(name: .constant(CDItem.preview.displayName),
                price: .constant(CDItem.preview.price),
                addAction: { },
                onDismiss: { })
        .environment(\.locale, Locale(identifier: "en-IN"))
}

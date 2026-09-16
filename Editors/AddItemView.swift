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
    
    @Environment(\.locale) private var locale
    
    private enum Field: Hashable {
        case name
        case price
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        HStack {
            Label("Checkcircle", systemImage: "circle")
                .imageScale(.large)
                .labelStyle(.iconOnly)
                .foregroundStyle(Color.accentColor)
                .padding(.trailing, Design.Padding.trailing)
            
            VStack {
                TextField("Item Name", text: $name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .price
                    }
                Divider()
                TextField("Price",
                          value: $price,
                          format: .currency(code: locale.currency?.identifier ?? "USD"))
                .keyboardType(.numbersAndPunctuation)
                .focused($focusedField, equals: .price)
                .submitLabel(.done)
                .onSubmit {
                    if !name.isEmpty && price != nil {
                        addAction()
                        name = ""
                        price = nil
                    }
                    focusedField = nil
                }
            }
        }
        .onAppear {
            name = ""
            price = nil
            focusedField = .name
        }
    }
}

#Preview {
    AddItemView(name: .constant(CDItem.preview.displayName),
                price: .constant(CDItem.preview.price),
                addAction: { })
    .environment(\.locale, Locale(identifier: "en-IN"))
}

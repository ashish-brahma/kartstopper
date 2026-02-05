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
    @Binding var price: Double
    @FocusState private var isEditing
    
    @Environment(\.locale) private var locale
    
    var body: some View {
        HStack {
            Label("Checkcircle", systemImage: "circle")
                .imageScale(.large)
                .labelStyle(.iconOnly)
                .foregroundStyle(Color.accentColor)
                .padding(.trailing, Design.Padding.trailing)
            
            VStack {
                TextField("Item Name", text: $name)
                    .focused($isEditing)
                Divider()
                TextField("Price",
                          value: $price,
                          format: .currency(code: locale.currency?.identifier ?? "USD"),
                          prompt: Text("Price"))
                .keyboardType(.decimalPad)
            }
        }
        .onAppear {
            name = ""
            price = 0.00
            isEditing = true
        }
    }
}

#Preview {
    AddItemView(name: .constant(CDItem.preview.displayName),
                price: .constant(CDItem.preview.price))
        .environment(\.locale, Locale(identifier: "en-IN"))
}

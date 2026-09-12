//
//  AddCartView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  A SwiftUI view that adds a new cart.

import SwiftUI
import CoreData

struct AddCartView: View {
    @Binding var name: String
    @Binding var notes: String
    @FocusState private var isAddingName
    @FocusState private var isAddingNotes
    
    var body: some View {
        VStack {
            TextField("Cart Name", text: $name)
                .focused($isAddingName)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .submitLabel(.next)
                .onSubmit {
                    isAddingNotes = true
                }
            Divider()
            TextField("Add notes (optional)",
                      text: $notes,
                      axis: .vertical)
            .textInputAutocapitalization(.sentences)
            .frame(height: Design.descriptionFieldHeight,
                   alignment: .top)
            .lineLimit(Design.descriptionFieldLineLimit)
            .focused($isAddingNotes)
        }
        .onAppear {
            name = ""
            notes = ""
            isAddingName = true
        }
    }
}

#Preview {
    NavigationStack {
        AddCartView(name: .constant(CDCart.preview.displayName),
                    notes: .constant(CDCart.preview.displayNotes))
    }
}

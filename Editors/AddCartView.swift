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
    
    private enum Field: Hashable {
        case name
        case notes
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            TextField("Cart Name", text: $name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .notes
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
        .onAppear {
            name = ""
            notes = ""
            focusedField = .name
        }
    }
}

#Preview {
    NavigationStack {
        AddCartView(name: .constant(CDCart.preview.displayName),
                    notes: .constant(CDCart.preview.displayNotes))
    }
}

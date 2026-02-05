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
    @FocusState private var isEditing
    
    var body: some View {
        VStack {
            TextField("Cart Name", text: $name)
                .focused($isEditing)
            Divider()
            TextField("Add notes (optional)",
                      text: $notes,
                      axis: .vertical)
            .lineLimit(Design.descriptionFieldLineLimit)
            .frame(height: Design.descriptionFieldHeight, alignment: .top)
        }
        .onAppear {
            isEditing = true
        }
    }
}

#Preview {
    NavigationStack {
        AddCartView(name: .constant(CDCart.preview.displayName),
                    notes: .constant(CDCart.preview.displayNotes))
    }
}

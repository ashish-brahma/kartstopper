//
//  AddToolbarButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 16/09/26.
//
//  A SwiftUI button view that is used to add a new entry in a list.

import SwiftUI

struct AddToolbarButton: View {
    let entityName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Add \(entityName)", systemImage: "plus")
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
    }
}

#Preview {
    AddToolbarButton(entityName: "cart",
                     action: { })
}

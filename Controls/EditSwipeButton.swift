//
//  EditSwipeButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 11/09/26.
//
//  A SwiftUI button view that is used to edit cart/item data.

import SwiftUI

struct EditSwipeButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Edit", systemImage: "pencil")
                .tint(.edit)
                .labelStyle(.iconOnly)
        }
    }
}

#Preview {
    EditSwipeButton { }
}

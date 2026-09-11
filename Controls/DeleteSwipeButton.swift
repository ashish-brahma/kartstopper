//
//  DeleteSwipeButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 11/09/26.
//
//  A SwiftUI button view that is used to delete cart/item data.

import SwiftUI

struct DeleteSwipeButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(role: .destructive, action: action) {
            Label("Delete", systemImage: "trash")
                .labelStyle(.iconOnly)
        }
    }
}

#Preview {
    DeleteSwipeButton { }
}

//
//  CancelToolbarButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 16/09/26.
//
//  A SwiftUI button view that is used to cancel editor action.

import SwiftUI

struct CancelToolbarButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Cancel", systemImage: "xmark")
        }
    }
}

#Preview {
    CancelToolbarButton(action: { })
}

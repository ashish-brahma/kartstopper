//
//  ConfirmToolbarButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 16/09/26.
//
//  A SwiftUI button view that is used to confirm editor action.

import SwiftUI

struct ConfirmToolbarButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label("Done", systemImage: "checkmark")
        }
    }
}

#Preview {
    ConfirmToolbarButton(action: { })
}

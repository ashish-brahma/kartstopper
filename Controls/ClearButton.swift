//
//  ClearButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 23/11/26.
//
//  A SwiftUI button view that is used to clear the text in textfield during input.

import SwiftUI

struct ClearButton: View {
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(Color(.secondarySystemFill))
            Image(systemName: "xmark")
                .foregroundStyle(.primary)
                .imageScale(.small)
        }
        .frame(height: 30)
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    ClearButton(action: {})
}

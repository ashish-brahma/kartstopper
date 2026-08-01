//
//  ExpandButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 09/01/26.
//
//  A SwiftUI button view which is used to expand chart data.

import SwiftUI

struct ExpandButton: View {
    @Binding var showAllData: Bool
    
    var body: some View {
        Button {
            showAllData.toggle()
        } label: {
            Text(showAllData ? "Show Less" : "Show More")
        }
    }
}

#Preview {
    ExpandButton(showAllData: .constant(false))
}

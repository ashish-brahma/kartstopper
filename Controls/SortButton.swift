//
//  SortButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 09/01/26.
//
//  A SwiftUI button view which sets sort parameter of chart data.

import SwiftUI

struct SortButton: View {
    @Binding var value: SortParameter
    
    var body: some View {
        Picker(selection: $value) {
            Text("Decreasing Expenses").tag(SortParameter.expense)
            Text("Latest First").tag(SortParameter.time)
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
        .pickerStyle(.menu)
    }
}

enum SortParameter {
    case expense
    case time
}

#Preview {
    SortButton(value: .constant(.expense))
}

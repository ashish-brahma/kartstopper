//
//  AddItemEditorButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 30/10/26.
//
//  A SwiftUI button view that displays add item view in checklist.

import SwiftUI

struct AddItemEditorButton: View {
    @Binding var showAddItem: Bool
    let proxy: GeometryProxy
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Button {
            showAddItem = true
        } label: {
            itemEditorRow(proxy: proxy)
        }
    }
    
    @ViewBuilder
    private func itemEditorRow(proxy: GeometryProxy) -> some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                HStack {
                    Label("Checkcircle", systemImage: "circle")
                        .imageScale(.large)
                        .labelStyle(.iconOnly)
                        .foregroundStyle(Color.accentColor)
                        .padding(.trailing, Design.Padding.trailing)
                    
                    VStack(alignment: .leading) {
                        Text("Item Name")
                        Divider()
                        Text("Price")
                    }
                    .foregroundStyle(.gray)
                }
                .padding(Design.Padding.standard)
                .background {
                    RoundedRectangle(cornerRadius: Design.cornerRadius)
                        .fill(Color(.tertiarySystemFill))
                }
            }
            .frame(maxWidth: horizontalSizeClass == .regular ?  Design.addItemMaxWidth : proxy.size.width/1.2)
            Spacer()
        }
        .padding(.bottom, Design.Padding.bottom * 2)
    }
}

#Preview {
    GeometryReader { proxy in
        AddItemEditorButton(
            showAddItem: .constant(true),
            proxy: proxy
        )
    }
}

//
//  ItemOverviewLabel.swift
//  KartStopper
//
//  Created by Ashish Brahma on 20/09/26.
//
//  A SwiftUI view that displays select metadata in
//  the row view of an item.

import SwiftUI

struct ItemOverviewLabel: View {
    let imageURL: URL?
    let name: String
    let price: Double
    let details: String
    let itemColor: Color
    let proxy: GeometryProxy
    
    var body: some View {
        HStack(alignment: .top) {
            if imageURL != nil {
                displayImage(imageURL: imageURL)
            } else {
                placeholderImage(name: name,
                                 itemColor: itemColor)
            }
            
            columnLabel()
        }
    }
    
    private func columnLabel() -> some View {
        VStack(alignment: .leading) {
            Text(name)
                .foregroundStyle(Color.foreground)
                .font(.system(size: Design.itemNameFontSize, weight: .medium))
                .multilineTextAlignment(.leading)
            
            Text(price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.bottom, 1)
            
            Text(details)
                .font(.footnote)
                .multilineTextAlignment(.leading)
                .lineLimit(Design.displayNotesLineLimit)
                .minimumScaleFactor(Design.notesMinScaleFactor)
            
            Spacer()
        }
        .foregroundStyle(.secondary)
    }
    
    private func displayImage(imageURL: URL?) -> some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(
            maxWidth: proxy.size.width/6,
            maxHeight: proxy.size.width/6,
        )
        .padding(.trailing)
    }
    
    private func placeholderImage(
        name: String,
        itemColor: Color
    ) -> some View {
        RoundedRectangle(cornerRadius: Design.avatarCornerRadius)
            .fill(itemColor)
            .overlay {
                Text(String(name.first!))
                    .font(.system(size: Design.avatarTextFontSize))
            }
            .frame(
                maxWidth: proxy.size.width/6,
                maxHeight: proxy.size.width/6,
            )
            .padding(.trailing)
    }
}

#Preview {
    let item = CDItem.preview
    GeometryReader { proxy in
        List {
            ItemOverviewLabel(
                imageURL: nil,
                name: item.displayName,
                price: item.price,
                details: item.displayNotes,
                itemColor: item.itemColor,
                proxy: proxy
            )
        }
    }
}

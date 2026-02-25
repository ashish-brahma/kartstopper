//
//  ItemRowView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  A SwiftUI view that shows metadata of an item in a cart.

import SwiftUI

struct ItemRowView: View {
    let imageURL: URL?
    let name: String
    let price: Double
    var itemColor: Color
    let reader: GeometryProxy
    
    var body: some View {
        HStack(alignment: .top) {
            if imageURL != nil {
                displayImage()
            } else {
                placeholderImage()
            }
            
            itemDetails()
        }
    }
    
    private func itemDetails() -> some View {
        VStack(alignment: .leading) {
            Text(name)
                .foregroundStyle(Color.foreground)
                .multilineTextAlignment(.leading)
                .font(.system(size: Design.itemNameFontSize, weight: .medium))
            
            displayPrice()
        }
        .foregroundStyle(.secondary)
    }
    
    private func displayImage() -> some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            ProgressView()
        }
        .frame(
            maxWidth: reader.size.width/6,
            maxHeight: reader.size.width/6,
        )
        .padding(.trailing)
    }
    
    private func placeholderImage() -> some View {
        RoundedRectangle(cornerRadius: Design.avatarCornerRadius)
            .fill(itemColor)
            .overlay {
                Text(String(name.first!))
                    .font(.system(size: Design.avatarTextFontSize))
            }
            .frame(
                maxWidth: reader.size.width/6,
                maxHeight: reader.size.width/6
            )
            .padding(.trailing)
    }
    
    private func displayPrice() -> some View {
        Text(price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
            .font(.title2)
    }
}

#Preview() {
    let item = CDItem.preview
    GeometryReader { reader in
        ItemRowView(imageURL: item.imageURL,
                    name: item.displayName,
                    price: item.price,
                    itemColor: item.itemColor,
                    reader: reader)
        .position(x: reader.size.width/2, y: reader.size.height/2)
    }
}

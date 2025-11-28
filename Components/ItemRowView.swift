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
    let date: String
    let name: String
    let price: Double
    let reader: GeometryProxy
    let isSearching: Bool
    
    var itemColor: Color {
        let seed = name.hashValue
        var generator: RandomNumberGenerator = SeededRandomGenerator(seed: seed)
        return .random(using: &generator)
    }
    
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
            if !isSearching {
                displayDate()
            }
            
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
    
    private func displayDate() -> some View {
        Text(date)
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.leading)
            .padding(.vertical, Design.Padding.vertical)
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
                    date: item.displayDate,
                    name: item.displayName,
                    price: item.price,
                    reader: reader,
                    isSearching: true)
        .frame(height: reader.size.height/5)
        .position(x: reader.size.width/2, y: reader.size.height/2)
    }
}

//
//  ItemDetailView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 24/11/25.
//
//  A SwiftUI view that shows details of an item.

import SwiftUI

struct ItemDetailView: View {
    let imageURL: URL?
    let name: String
    let price: Double
    let notes: String
    
    private var itemColor: Color {
        let seed = name.hashValue
        var generator: RandomNumberGenerator = SeededRandomGenerator(seed: seed)
        return .random(using: &generator)
    }
    
    var body: some View {
        GeometryReader {reader in
            ScrollView {
                VStack(alignment: .leading) {
                    if imageURL != nil {
                        displayImage(reader: reader)
                    } else {
                        placeholderImage(reader: reader)
                    }
                    
                    itemDetails()
                }
            }
            .navigationTitle(name)
            .navigationTitleColor(Color.foreground)
        }
    }
    
    private func itemDetails() -> some View {
        VStack(alignment: .leading) {
            Text(price.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
                .font(.title)
                .foregroundStyle(Color.foreground)
                .padding(.bottom)
            
            Text(notes)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(Design.notesMinScaleFactor)
        }
        .padding()
    }
    
    private func displayImage(reader: GeometryProxy) -> some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()
                .clipShape(.rect(cornerRadius: Design.avatarDetailCornerRadius))
        } placeholder: {
            ProgressView()
        }
        .frame(width: reader.size.width/1.07,
               height: reader.size.height/2)
        .position(x: reader.size.width/2,
                  y: reader.size.height/3.8)
        .padding(.bottom)
    }
    
    private func placeholderImage(reader: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: Design.avatarDetailCornerRadius)
            .fill(itemColor)
            .overlay {
                Text(String(name.first!))
                    .font(.system(size: Design.avatarDetailTextFontSize))
            }
            .frame(width: reader.size.width/1.07,
                   height: reader.size.height/2)
            .position(x: reader.size.width/2,
                      y: reader.size.height/3.8)
            .padding(.bottom)
    }
}

#Preview {
    let item = CDItem.preview
    NavigationStack {
        ItemDetailView(imageURL: item.imageURL,
                       name: item.displayName,
                       price: item.price,
                       notes: item.displayNotes)
    }
}

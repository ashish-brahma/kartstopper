//
//  CartRowView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 05/11/25.
//
//  A view that shows cart metadata.

import SwiftUI
import CoreData

struct CartRowView: View {
    @ObservedObject var cart: CDCart
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private var totalItems: Int {
        CDCart.getTotalItems(for: cart, context: viewContext)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(cart.displayDate.formatted(date: .omitted,
                                            time: .shortened))
                .font(.subheadline)
            
            HStack {
                Text(cart.displayName)
                    .font(.largeTitle)
                    .foregroundStyle(Color.foreground)
                Spacer()
                Text("\(totalItems)")
                    .font(.system(size: Design.itemCountFontSize, weight: .semibold))
                    .padding(.trailing, Design.Padding.trailing)
            }
            
            Text(cart.displayNotes)
                .font(.footnote)
                .minimumScaleFactor(Design.notesMinScaleFactor)
                .frame(alignment: .leading)
        }
        .foregroundStyle(.secondary)
    }
}

#Preview {
    GeometryReader { reader in
        CartRowView(cart: .preview)
            .position(x: reader.size.width/2, y: reader.size.height/2)
            .environment(\.managedObjectContext,
                          PersistenceController.preview.container.viewContext)
    }
}

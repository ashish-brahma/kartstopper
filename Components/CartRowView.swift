//
//  CartRowView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 05/11/25.
//
//  A SwiftUI view that shows cart metadata.

import SwiftUI
import CoreData

struct CartRowView: View {
    @ObservedObject var cart: CDCart
    @ObservedObject var navModel: NavigationModel
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private var totalItems: Int {
        CDCart.getTotalItems(for: cart, context: viewContext)
    }
    
    private var isSelected: Bool {
        navModel.selectedCart == cart
    }
    
    var body: some View {
        NavigationLink(value: cart) {
            VStack(alignment: .leading) {
                Text(cart.displayDate.formatted(date: .omitted,
                                                time: .shortened))
                .font(.subheadline)
                
                HStack {
                    Text(cart.displayName)
                        .font(.largeTitle)
                        .foregroundStyle(isSelected ? Color.white : Color.foreground)
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
            .foregroundStyle(isSelected ? Color.white : .secondary)
        }
    }
}

#Preview("Not Selected") {
    GeometryReader { proxy in
        CartRowView(cart: .preview,
                    navModel: NavigationModel())
        .position(x: proxy.size.width/2, y: proxy.size.height/2)
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
    }
}

#Preview("Selected") {
    let navModel = NavigationModel()
    let cart = CDCart.preview
    
    GeometryReader { proxy in
        CartRowView(cart: cart,
                    navModel: navModel)
        .background(.blue)
        .position(x: proxy.size.width/2, y: proxy.size.height/2)
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
        .task {
            navModel.selectedCart = cart
        }
    }
}

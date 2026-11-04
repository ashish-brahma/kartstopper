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
    
    var isSidebarAvailable: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    
    private var totalItems: Int {
        CDCart.getTotalItems(for: cart, context: viewContext)
    }
    
    private var isSelected: Bool {
        navModel.selectedCart == cart
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(cart.displayDate.formatted(date: .omitted,
                                            time: .shortened))
            .font(.subheadline)
            
            HStack {
                Text(cart.displayName)
                    .font(.largeTitle)
                    .foregroundStyle(getColor(for: .foreground))
                Spacer()
                Text("\(totalItems)")
                    .font(.system(size: Design.itemCountFontSize, weight: .semibold))
                    .padding(.trailing, Design.Padding.trailing)
            }
            
            Text(cart.displayNotes)
                .font(.footnote)
                .minimumScaleFactor(Design.notesMinScaleFactor)
                .multilineTextAlignment(.leading)
                .lineLimit(Design.displayNotesLineLimit)
        }
        .foregroundStyle(getColor(for: .secondary))
    }
    
    private func getColor(for color: Color) -> Color {
        var selectionColor: Color
        
        if #available(iOS 17, *) {
            selectionColor = color
        } else {
            selectionColor = .white
        }
        
        return isSelected && isSidebarAvailable ? selectionColor : color
    }
}

#Preview("Not Selected") {
    @ObservedObject var navModel = NavigationModel()
    let cart = CDCart.preview
    
    NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
        List {
            NavigationLink(value: cart) {
                CartRowView(
                    cart: cart,
                    navModel: navModel,
                    isSidebarAvailable: true
                )
            }
        }
    } detail: {
        
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

#Preview("Selected") {
    @ObservedObject var navModel = NavigationModel()
    let cart = CDCart.preview
    
    NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
        List(selection: $navModel.selectedCart) {
            NavigationLink(value: cart) {
                CartRowView(
                    cart: cart,
                    navModel: navModel,
                    isSidebarAvailable: true
                )
            }
        }
    } detail: {
        
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
    .task {
        navModel.selectedCart = cart
    }
}

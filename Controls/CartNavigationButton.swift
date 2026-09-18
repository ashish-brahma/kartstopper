//
//  NavigationButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 18/09/26.
//
//  A SwiftUI button view that presents a cart's checklist.

import SwiftUI
import CoreData

struct CartNavigationButton: View {
    @ObservedObject var navModel: NavigationModel
    
    let cart: CDCart
    let deleteAction: () -> Void
    let editAction: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                navModel.presentedCarts.append(cart)
            }
        } label: {
            CartRowView(cart: cart)
        }
        .swipeActions(edge: .trailing) {
            DeleteSwipeButton(action: deleteAction)
        }
        .swipeActions(edge: .trailing) {
            EditSwipeButton(action: editAction)
        }
    }
}

#Preview {
    CartNavigationButton(navModel: NavigationModel(),
                         cart: .preview,
                         deleteAction: { },
                         editAction: { })
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

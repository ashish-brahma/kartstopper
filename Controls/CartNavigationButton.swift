//
//  NavigationButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 18/09/26.
//
//  A SwiftUI button view that presents a cart's checklist.

import SwiftUI
import CoreData
internal import Combine

struct CartNavigationButton: View {
    @ObservedObject var navModel: NavigationModel
    
    let cart: CDCart
    @Binding var showEditCart: Bool
    let onDelete: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                navModel.presentedCarts.append(cart)
            }
        } label: {
            CartRowView(cart: cart)
        }
        .swipeActions(edge: .trailing) {
            DeleteSwipeButton(action: onDelete)
        }
        .swipeActions(edge: .trailing) {
            EditSwipeButton {
                navModel.selectedCart = cart
                showEditCart = true
            }
        }
    }
}

#Preview {
    CartNavigationButton(
        navModel: NavigationModel(),
        cart: .preview,
        showEditCart: .constant(false),
        onDelete: { }
    )
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
}

//
//  CartsToolbar.swift
//  KartStopper
//
//  Created by Ashish Brahma on 18/09/26.
//
//  A SwiftUI view that configures toolbar content of carts' navigation stack.

import SwiftUI
import CoreData
internal import OSLog

struct CartsToolbar: ToolbarContent {
    @ObservedObject var viewModel: ViewModel
    
    let logger = PersistenceController.shared.logger
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var showAddCart: Bool
    @Binding var cartsEmpty: Bool
    @Binding var name: String
    @Binding var notes: String
    
    var body: some ToolbarContent {
        if showAddCart {
            ToolbarItem(placement: .cancellationAction) {
                CancelToolbarButton { showAddCart = false }
            }
            ToolbarItem(placement: .confirmationAction) {
                ConfirmToolbarButton {
                    addCart()
                    showAddCart = false
                }
                .disabled(name.isEmpty)
            }
        } else {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
                    .disabled(cartsEmpty)
            }
            ToolbarItem(placement: .primaryAction) {
                AddToolbarButton(entityName: "cart") {
                    showAddCart = true
                }
                .disabled(showAddCart)
            }
        }
    }
    
    private func saveContext(cart: CDCart) {
        do {
            try viewContext.save()
        } catch {
            if !cart.isInserted {
                logger.error("Failed to insert new cart. \(error.localizedDescription)")
            }
        }
    }
    
    private func addCart() {
        withAnimation {
            let newCart = CDCart(context: viewContext)
            newCart.id = Int32(viewModel.totalCarts + 1)
            newCart.name = name
            newCart.timestamp = Date()
            newCart.notes = notes
            saveContext(cart: newCart)
            viewModel.update(context: viewContext)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            CartRowView(cart: .preview)
        }
        .navigationTitle("Carts")
        .toolbar {
            CartsToolbar(
                viewModel: .preview,
                showAddCart: .constant(false),
                cartsEmpty: .constant(false),
                name: .constant(CDCart.preview.displayName),
                notes: .constant(CDCart.preview.notes ?? "")
            )
        }
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
    
}

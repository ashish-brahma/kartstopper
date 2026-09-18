//
//  CartsToolbar.swift
//  KartStopper
//
//  Created by Ashish Brahma on 18/09/26.
//
//  A SwiftUI view that configures toolbar content of carts' navigation stack.

import SwiftUI
import CoreData

struct CartsToolbar: ToolbarContent {
    @Binding var showAddCart: Bool
    @Binding var disableConfirm: Bool
    @Binding var disableEdit: Bool
    
    let addAction: () -> Void
    
    var body: some ToolbarContent {
        if showAddCart {
            ToolbarItem(placement: .cancellationAction) {
                CancelToolbarButton { showAddCart = false }
            }
            ToolbarItem(placement: .confirmationAction) {
                ConfirmToolbarButton {
                    addAction()
                    showAddCart = false
                }
                .disabled(disableConfirm)
            }
        } else {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
                    .disabled(disableEdit)
            }
            ToolbarItem(placement: .primaryAction) {
                AddToolbarButton(entityName: "cart") {
                    showAddCart = true
                }
                .disabled(showAddCart)
            }
        }
    }
}

#Preview {
    NavigationStack {
        List {
            CartNavigationButton(navModel: NavigationModel(),
                                 cart: .preview,
                                 deleteAction: { },
                                 editAction: { })
        }
        .navigationTitle("Carts")
        .toolbar {
            CartsToolbar(showAddCart: .constant(false),
                         disableConfirm: .constant(false),
                         disableEdit: .constant(false),
                         addAction: { })
        }
    }
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
    
}

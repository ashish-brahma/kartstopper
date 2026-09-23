//
//  QuantityStepper.swift
//  KartStopper
//
//  Created by Ashish Brahma on 20/09/26.
//
//  A SwiftUI stepper view that is used to change an item's quantity.

import SwiftUI
import CoreData
internal import Combine
internal import OSLog

struct QuantityStepper: View {
    @ObservedObject var viewModel: ViewModel
    
    let logger = PersistenceController.shared.logger
    
    @Environment(\.managedObjectContext) private var viewContext
    
    let item: CDItem
    
    var body: some View {
        Stepper {
            Text("Quantity: \(item.quantity)")
                .foregroundStyle(.secondary)
        } onIncrement: {
            viewModel.objectWillChange.send()
            item.quantity += 1
            saveContext()
        } onDecrement: {
            viewModel.objectWillChange.send()
            item.quantity -= 1
            if item.quantity < 1 {
                item.quantity = 1
            }
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            if !item.isUpdated {
                logger.error("Failed to update item's quantity. \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    QuantityStepper(viewModel: .preview,
                    item: .preview)
    .environment(\.managedObjectContext,
                  PersistenceController.preview.container.viewContext)
    
}

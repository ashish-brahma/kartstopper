//
//  PreviewSampleData.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/11/25.
//
//  Sample data for use in previews.

import Foundation
import CoreData

extension PersistenceController {
    /// An in-memory container for displaying sample data in previews.
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Insert sample carts and items.
        for i in 0...4 {
            let sampleCart = CDCart(context: viewContext)
            sampleCart.id = Int32(i)
            sampleCart.timestamp = Date.random()
            sampleCart.name = "Cart \(i+1)"
            insertPreviewItems(in: sampleCart, withCount: i+1, context: viewContext)
            sampleCart.notes = """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ultricies mauris ante.
            """
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    static func insertPreviewItems(
        in cart: CDCart,
        withCount count: Int,
        context: NSManagedObjectContext
    ) {
        for i in 0...count-1 {
            let sampleItem = CDItem(context: context)
            sampleItem.id = Int32(i)
            sampleItem.isComplete = true
            sampleItem.timestamp = Date.random()
            sampleItem.price = Double.random(in: 100...320)
            sampleItem.quantity = Int32.random(in: 1...4)
            sampleItem.name = "Item \(i+1)"
            sampleItem.notes = """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ultricies mauris ante.
            """
            sampleItem.cart = cart
        }
    }
}

extension CDCart {
    static var preview: CDCart {
        let result = PersistenceController.preview
        let viewContext = result.container.viewContext
        let cart = CDCart(context: viewContext)
        cart.id = Int32(1)
        cart.name = "Cart Title"
        cart.notes = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ultricies mauris ante.
        """
        cart.timestamp = Date.random()
        cart.addToItems(.preview)
        return cart
    }
}

extension CDItem {
    static var preview: CDItem {
        let result = PersistenceController.preview
        let viewContext = result.container.viewContext
        let item = CDItem(context: viewContext)
        item.id = Int32(1)
        item.name = "Item Title"
        item.isComplete = Bool.random()
        item.timestamp = Date.random()
        item.price = Double.random(in: 0...20)
        item.notes = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ultricies mauris ante.
        """
        return item
    }
}

extension ViewModel {
    static var preview: ViewModel {
        .init(budget: Budget(totalMonthlySpend: 1000.00,
                             budgetAmount: 5500.00,
                             budgetMode: .medium,
                             isLocked: false),
              hasOnboarded: true)
    }
}

extension Date {
    /// Returns random date and time.
    static func random() -> Date {
        var components = DateComponents()
        components.day = Int.random(in: 1...30)
        components.month = Int.random(in: 4...5)
        components.year = Calendar.current.component(.year, from: .now)
        components.hour = Int.random(in: 1...24)
        components.minute = Int.random(in: 1...60)
        components.second = Int.random(in: 1...60)
        
        let date = Calendar.current.date(from: components) ?? .now
        return date
    }
}

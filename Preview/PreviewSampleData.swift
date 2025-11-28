//
//  PreviewSampleData.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/11/25.
//

import Foundation
import CoreData

extension PersistenceController {
    /// An in-memory container for displaying sample data in previews.
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Insert sample carts and items.
        for i in 0...2 {
            let sampleCart = CDCart(context: viewContext)
            sampleCart.id = Int32(i)
            sampleCart.timestamp = Date()
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
            sampleItem.timestamp = Date()
            sampleItem.price = Double.random(in: 0...20)
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
        cart.timestamp = Date()
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
        item.timestamp = Date()
        item.price = 20.00
        item.notes = """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ultricies mauris ante.
        """
        return item
    }
}

extension ViewModel {
    static var preview: ViewModel {
        .init()
    }
}

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
        
        insertPreviewItems(context: viewContext)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    // Insert sample carts and items.
    static func insertPreviewItems(context: NSManagedObjectContext) {
        let cart1 = CDCart(context: context)
        cart1.id = Int32(0)
        cart1.timestamp = Date.previewDate(year: 2023, month: 11, day: 9)
        cart1.name = "Therapy"
        cart1.notes = "Boutique items from spa."
        
        let item1 = CDItem(context: context)
        item1.id = Int32(0)
        item1.isComplete = true
        item1.timestamp = Date.previewDate(year: 2023, month: 11, day: 9)
        item1.price = 350.00
        item1.quantity = 5
        item1.name = "Sesame oil"
        item1.notes = "Oil for body massage"
        item1.cart = cart1
        
        let item2 = CDItem(context: context)
        item2.id = Int32(1)
        item2.isComplete = true
        item2.timestamp = Date.previewDate(year: 2024, month: 2, day: 29)
        item2.price = 200.00
        item2.quantity = 5
        item2.name = "Towels"
        item2.notes = "Gentle material which aborbs maximum moisture."
        item2.cart = cart1
        
        let item3 = CDItem(context: context)
        item3.id = Int32(2)
        item3.isComplete = true
        item3.timestamp = Date.previewDate(year: 2024, month: 3, day: 4)
        item3.price = 2500.00
        item3.quantity = 1
        item3.name = "Pumice Stone"
        item3.notes = "Feet scrubber"
        item3.cart = cart1
        
        let item4 = CDItem(context: context)
        item4.id = Int32(3)
        item4.isComplete = true
        item4.timestamp = Date.previewDate(year: 2024, month: 3, day: 6)
        item4.price = 1000.00
        item4.quantity = 1
        item4.name = "Weighing Scale"
        item4.notes = "Measure body weight"
        item4.cart = cart1
        
        let item5 = CDItem(context: context)
        item5.id = Int32(4)
        item5.isComplete = true
        item5.timestamp = Date.previewDate(year: 2024, month: 3, day: 7)
        item5.price = 100.00
        item5.quantity = 1
        item5.name = "Breathable strap"
        item5.notes = "Sweat absorption material for wrist, knees and waist."
        item5.cart = cart1
        
        let cart2 = CDCart(context: context)
        cart2.id = Int32(1)
        cart2.timestamp = Date.previewDate(year: 2024, month: 2, day: 28)
        cart2.name = "Gadgets"
        cart2.notes = "Workout companions."
        
        let item6 = CDItem(context: context)
        item6.id = Int32(5)
        item6.isComplete = true
        item6.timestamp = Date.previewDate(year: 2024, month: 2, day: 28)
        item6.price = 3520.52
        item6.quantity = 1
        item6.name = "JBL Earbuds"
        item6.notes = "In-ear wireless with sweat protection, ANC and ambient noise control."
        item6.cart = cart2
        
        let cart3 = CDCart(context: context)
        cart3.id = Int32(2)
        cart3.timestamp = Date.previewDate(
            year:   2024,
            month:  2,
            day:    28,
            hour:   10,
            minute: 13,
            second: 26
        )
        cart3.name = "Food & Beverages"
        cart3.notes = "Fitness diet"
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
        cart.timestamp = Date.sampleDate()
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
        item.isComplete = true
        item.timestamp = Date.sampleDate()
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
                             isLocked: true),
              hasOnboarded: true)
    }
}

extension Date {
    // Provide a sample date and time.
    static func sampleDate() -> Date {
        var components = DateComponents()
        components.day = 4
        components.month = 4
        components.year = 2024
        components.hour = 09
        components.minute = 41
        components.second = 24
        
        let date = Calendar.current.date(from: components) ?? .now
        return date
    }
    
    // Create a preview date from components.
    static func previewDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 09,
        minute: Int = 41,
        second: Int = 24
    ) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.hour = hour
        components.minute = minute
        components.second = second
        
        let date = Calendar.current.date(from: components) ?? .now
        return date
    }
}

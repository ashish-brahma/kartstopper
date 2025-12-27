//
//  CDCart+Extension.swift
//  KartStopper
//
//  Created by Ashish Brahma on 02/10/25.
//
//  The model class of carts.

import CoreData

extension CDCart {
    var displayName: String {
        guard let name, !name.isEmpty
        else { return "Untitled Cart" }
        return name
    }
    
    var displayNotes: String {
        guard let notes, !notes.isEmpty
        else { return "" }
        return notes
    }
    
    var displayDate: String {
        guard let timestamp, !timestamp.formatted().isEmpty
        else { return "Undated" }
        return timestamp.formatted(Date.customStyle)
    }
    
    static func getTotalCarts(context: NSManagedObjectContext) -> Int {
        guard let count = try? context.count(for: CDCart.fetchRequest()), count != 0
        else { return 0 }
        return count
    }
    
    static func getTotalItems(
        for cart: CDCart,
        context: NSManagedObjectContext
    ) -> Int {
        let request = CDItem.fetchRequest()
        request.predicate = NSPredicate(format: "cart.name = %@", cart.name ?? "")
        guard let count = try? context.count(for: request), count != 0
        else { return 0 }
        return count
    }
    
    static func getTotalMonthlySpend(context: NSManagedObjectContext) -> Double {
        let request = CDItem.fetchRequest()
        let start = Date.startOfMonth(from: .now) as NSDate
        let end = Date.now as NSDate
        
        request.predicate = NSPredicate(format: "isComplete == true && %K >= %@ && %K <= %@",
                                                "timestamp", start, "timestamp", end)
        
        guard let items = try? context.fetch(request), items.count != 0
        else { return 0.00 }
        
        let amount = items.map { $0.price * Double($0.quantity) }.reduce(0, +)
        return amount
    }
}

// Date Formatting used for display.
extension Date {
    static var customStyle: Date.FormatStyle {
        Date.FormatStyle()
            .year(.defaultDigits)
            .month(.abbreviated)
            .day(.twoDigits)
            .hour(.twoDigits(amPM: .abbreviated))
            .minute(.twoDigits)
    }
    
    static func startOfMonth(from date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.month = Calendar.current.component(.month, from: date)
        components.year = Calendar.current.component(.year, from: date)
        return Calendar.current.date(from: components) ?? date
    }
}

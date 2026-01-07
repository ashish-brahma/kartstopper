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
    
    static func getTotalExpenses(
        for cart: CDCart,
        context: NSManagedObjectContext
    ) -> Double {
        let request = CDItem.fetchRequest()
        
        request.predicate = NSPredicate(format: "isComplete == true && cart.name = %@", cart.name ?? "")
        
        guard let items = try? context.fetch(request), items.count != 0
        else { return 0.00 }
        
        return items.map { $0.price * Double($0.quantity) }.reduce(0, +)
    }
    
    static func getTotalMonthlySpend(context: NSManagedObjectContext) -> Double {
        let start = Date.startOfMonth(from: .now)
        let end = Date.now
        
        let items = CDItem.getExpenditure(in: start...end,
                                          context: context)
        
        return items.map { $0.price * Double($0.quantity) }.reduce(0, +)
    }
}

extension Date {
    // Date Formatting used for display.
    static var customStyle: Date.FormatStyle {
        Date.FormatStyle()
            .year(.defaultDigits)
            .month(.abbreviated)
            .day(.twoDigits)
            .hour(.twoDigits(amPM: .abbreviated))
            .minute(.twoDigits)
    }
    
    // Extract start of the month from a given date
    static func startOfMonth(from date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.month = Calendar.current.component(.month, from: date)
        components.year = Calendar.current.component(.year, from: date)
        return Calendar.current.date(from: components) ?? date
    }
}

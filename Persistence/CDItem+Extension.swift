//
//  CDItem+Extension.swift
//  KartStopper
//
//  Created by Ashish Brahma on 02/10/25.
//
//  The model class of items.

import SwiftUI
import CoreData

extension CDItem {
    var displayName: String {
        guard let name, !name.isEmpty
        else { return "Unknown item" }
        return name
    }
    
    var displayNotes: String {
        guard let notes, !notes.isEmpty
        else { return "" }
        return notes
    }
    
    var displayDate: Date {
        guard let timestamp, !timestamp.formatted().isEmpty
        else { return .now }
        return timestamp
    }
    
    var itemColor: Color {
        let seed = name.hashValue
        var generator: RandomNumberGenerator = SeededRandomGenerator(seed: seed)
        return .random(using: &generator)
    }
    
    static func findItems(
        by name: String,
        in cart: String,
        context: NSManagedObjectContext
    ) -> Int {
        let request = CDItem.fetchRequest()
        var itemName = name
        let query = name.components(separatedBy: " ")
        if query.count > 1 {
            if let firstWord = query.first {
                itemName = firstWord
            }
        }
        request.predicate = NSPredicate(format: "name LIKE[cd] %@ && cart.name == %@", itemName, cart)
        guard let count = try? context.count(for: request), count != 0
        else { return 0 }
        return count
    }
    
    static func getTotalItems(context: NSManagedObjectContext) -> Int {
        guard let count = try? context.count(for: CDItem.fetchRequest()), count != 0
        else { return 0 }
        return count
    }
    
    static func getExpenditure(
        in range: ClosedRange<Date>,
        context: NSManagedObjectContext
    ) -> [CDItem]  {
        let request = CDItem.fetchRequest()
        let start = range.lowerBound as NSDate
        let end = range.upperBound as NSDate
        
        request.predicate = NSPredicate(format: "isComplete == true && %K >= %@ && %K <= %@",
                                        "completionDate", start, "completionDate", end)
        
        guard let items = try? context.fetch(request), items.count != 0
        else { return []}
        
        return items
    }
    
    static func dateRange(context: NSManagedObjectContext) -> ClosedRange<Date> {
        let request = CDItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDItem.completionDate, ascending: true)]
        guard let items = try? context.fetch(request), items.count != 0,
              let first = items.first?.completionDate,
              let last = items.last?.completionDate else { return .distantPast ... .distantFuture }
        return first...last
    }
}

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
    
    static func getExpenditure(
        in range: ClosedRange<Date>,
        context: NSManagedObjectContext
    ) -> [CDItem]  {
        let request = CDItem.fetchRequest()
        let start = range.lowerBound as NSDate
        let end = range.upperBound as NSDate
        
        request.predicate = NSPredicate(format: "isComplete == true && %K >= %@ && %K <= %@",
                                        "timestamp", start, "timestamp", end)
        
        guard let items = try? context.fetch(request), items.count != 0
        else { return []}
        
        return items
    }
    
    static func dateRange(context: NSManagedObjectContext) -> ClosedRange<Date> {
        let request = CDItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDItem.timestamp, ascending: true)]
        guard let items = try? context.fetch(request), items.count != 0,
              let first = items.first?.timestamp,
              let last = items.last?.timestamp else { return .distantPast ... .distantFuture }
        return first...last
    }
}

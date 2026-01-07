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
    
    var displayDate: String {
        guard let timestamp, !timestamp.formatted().isEmpty
        else { return "Undated" }
        return timestamp.formatted(Date.customStyle)
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
    
    // FIXME: Sort by date before fetch.
    static func dateRange(context: NSManagedObjectContext) -> ClosedRange<Date> {
        let request = CDItem.fetchRequest()
        guard let items = try? context.fetch(request), items.count != 0,
              let first = items.first?.timestamp,
              let last = items.last?.timestamp else { return .distantPast ... .distantFuture }
        return first...last
    }
}

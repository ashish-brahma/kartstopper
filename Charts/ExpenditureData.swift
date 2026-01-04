//
//  ExpenditureData.swift
//  KartStopper
//
//  Created by Ashish Brahma on 04/01/26.
//
//  Model structure of expenditure data.

import Foundation
import CoreData

struct ExpenditureData: Identifiable {
    let date: Date
    let expense: Double
    var id: Date { date }
}

extension ExpenditureData {
    static func periodicData(
        range: ClosedRange<Date>,
        context: NSManagedObjectContext
    ) -> [ExpenditureData] {
        let items = CDItem.getExpenditure(in: range,
                                          context: context)
        return items.map {
            ExpenditureData(date: $0.timestamp ?? .now,
                            expense: $0.price * Double($0.quantity))
        }
    }
}

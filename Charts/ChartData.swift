//
//  ChartData.swift
//  KartStopper
//
//  Created by Ashish Brahma on 04/01/26.
//
//  Model structures of chart data.

import Foundation
import CoreData

struct CartCountData: Identifiable {
    let name: String
    let itemCount: Int
    var id: String { name }
}

extension CartCountData {
    static func topCartsData(
        carts: Array<CDCart>,
        context: NSManagedObjectContext
    ) -> [CartCountData] {
        var data = [CartCountData]()
        
        for cart in carts {
            let count = CDCart.getTotalItems(for: cart,
                                             context: context)
            
            data.append(.init(name: cart.displayName,
                              itemCount: count))
        }
        
        data = data.sorted { $0.itemCount > $1.itemCount }
        return Array(data.prefix(5))
    }
    
    static func getMaxCount(data: [CartCountData]) -> Int? {
        data.map { $0.itemCount }.max()
    }
}

struct ExpenditureData: Identifiable {
    let name: String
    let cartName: String
    let date: Date
    let expense: Double
    var id: Date { date }
}

extension ExpenditureData {
    static func periodicData(
        range: ClosedRange<Date>,
        sortBy: SortParameter = .expense,
        context: NSManagedObjectContext
    ) -> [ExpenditureData] {
        let items = CDItem.getExpenditure(in: range,
                                          context: context)
        
        var data = items.map {
            ExpenditureData(name: $0.name ?? "",
                            cartName: $0.cart?.name ?? "",
                            date: $0.timestamp ?? .now,
                            expense: $0.price * Double($0.quantity))
        }
        
        data = data.sorted {
            switch sortBy {
            case .expense:
                $0.expense > $1.expense
            case .time:
                $0.date > $1.date
            }
        }
        
        return data
    }
    
    static func lastNDaysRange(
        days: TimeInterval,
        context: NSManagedObjectContext
    ) -> ClosedRange<Date> {
        let dateRange = CDItem.dateRange(context: context)
        let start = dateRange.upperBound.addingTimeInterval(-1 * 3600 * 24 * days)
        let end = dateRange.upperBound
        return start...end
    }
}

struct CartExpenseData: Identifiable {
    let name: String
    let date: Date
    let expense: Double
    var id: String { name }
}

extension CartExpenseData {
    static func topCartsData(
        range: ClosedRange<Date>,
        carts: Array<CDCart>,
        sortBy: SortParameter = .expense,
        context: NSManagedObjectContext
    ) -> [CartExpenseData] {
        var data = [CartExpenseData]()
        
        for cart in carts {
            let expense = CDCart.getTotalExpenses(for: cart,
                                                  in: range,
                                                  context: context)
            
            data.append(.init(name: cart.name ?? "",
                              date: cart.timestamp ?? .now,
                              expense: expense))
        }
        
        data = data.sorted {
            switch sortBy {
            case .expense:
                $0.expense > $1.expense
            case .time:
                $0.date > $1.date
            }
        }
        return data
    }
    
    static func getMaxExpense(data: [CartExpenseData]) -> Double? {
        data.map { $0.expense }.max()
    }
}

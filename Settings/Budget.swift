//
//  Budget.swift
//  KartStopper
//
//  Created by Ashish Brahma on 02/12/25.
//

import Foundation

struct Budget {
    /// Total amount spent.
    var totalMonthlySpend: Double = 0.00
    
    /// Amount allocated for monthly budget.
    var budgetAmount: Double = 0.00
    
    /// Difficulty mode used for budget monitoring.
    var budgetMode: Mode = .medium
    
    /// Flag to lock budget for editing.
    var isLocked: Bool = false
    
    /// Status indicator of budget.
    var status: Status = .positive
    
    /// Allow budget edits on the beginning of each month.
    mutating func updateBudgetLock(day: Int = Date.today) {
        isLocked = day == 1 ? false : true
    }
    
    /// Determine status by fraction of amount spend from the allocated budget amount.
    mutating func updateBudgetStatus() {
        switch(totalMonthlySpend/budgetAmount) {
        case 0.0..<0.5:
                status = .positive
        case 0.5..<0.8:
                status = .neutral
        default:
                status = .negative
        }
    }
    
    /// Difficulty levels to determine strictness of monitoring.
    enum Mode: String, CaseIterable, Identifiable {
        var id : String {
            UUID().uuidString
        }
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
    
    /// Categories to grade expenditure.
    enum Status: String, CaseIterable, Identifiable {
        var id : String {
            UUID().uuidString
        }
        case positive = "PositiveStatus"
        case neutral = "NeutralStatus"
        case negative = "NegativeStatus"
    }
}

extension Date {
    static var today: Int {
        Calendar.current.component(.day, from: .now)
    }
}

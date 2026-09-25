//
//  Budget.swift
//  KartStopper
//
//  Created by Ashish Brahma on 02/12/25.
//
//  A structure that sets up the financial model used for budgeting.
//  Parameters in the model are provided by user manually.

import Foundation
import SwiftUI

struct Budget: BudgetProtocol {
    /// Total amount spent.
    var totalMonthlySpend: Double = 0.00
    
    /// Amount allocated for monthly budget.
    var budgetAmount: Double? = nil
    
    /// Difficulty mode used for budget monitoring.
    var budgetMode: BudgetMode? = nil
    
    /// Flag to lock budget for editing.
    var isLocked: Bool = false
    
    /// Status indicator of budget.
    var status: Status = .unassigned
    
    /// Cutoff ratio used to check positive status.
    var positiveCutOff: Double {
        switch budgetMode {
        case .easy:
            0.7
        case .medium:
            0.5
        case .hard:
            0.35
        case .none:
            0.0
        }
    }
    
    /// Cutoff ratio used to check neurtal status.
    var neutralCutOff: Double {
        switch budgetMode {
        case .easy:
            0.95
        case .medium:
            0.8
        case .hard:
            0.65
        case .none:
            0.0
        }
    }
    
    /// Allow budget edits on the beginning of each month.
    mutating func updateBudgetLock(day: Int = Date.today) {
        isLocked = day == 1 ? false : true
    }
    
    /// Determine status by fraction of amount spend from the allocated budget amount.
    mutating func updateBudgetStatus() {
        guard let amount = budgetAmount else { return }
        guard let _ = budgetMode else { return }
        
        switch(totalMonthlySpend/amount) {
        case 0.0..<positiveCutOff:
            status = .positive
        
        case positiveCutOff..<neutralCutOff:
            status = .neutral
        
        case neutralCutOff...:
            status = .negative
        
        default:
            status = .unassigned
        }
    }
}

extension Date {
    static var today: Int {
        Calendar.current.component(.day, from: .now)
    }
}

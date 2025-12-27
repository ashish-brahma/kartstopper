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
    var budgetAmount: Double = 0.00
    
    /// Difficulty mode used for budget monitoring.
    var budgetMode: Mode = .medium
    
    /// Flag to lock budget for editing.
    var isLocked: Bool = false
    
    /// Status indicator of budget.
    var status: Status = .unassigned
    
    /// An array containing buget mode selected and saved by user
    var selectedModes: [Mode] {
        Mode.allCases.filter {
            $0.rawValue == UserDefaults.standard.string(forKey: "budgetMode")
        }
    }
    
    /// Cutoff ratio used to check positive status.
    var positiveCutOff: Double {
        switch budgetMode {
        case .easy:
            0.7
        case .medium:
            0.5
        case .hard:
            0.35
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
        }
    }
    
    /// Allow budget edits on the beginning of each month.
    mutating func updateBudgetLock(day: Int = Date.today) {
        isLocked = day == 1 ? false : true
    }
    
    /// Read preferences saved by user.
    mutating func updateBudgetSettings() {
        budgetAmount = UserDefaults.standard.double(forKey: "budgetAmount")
        budgetMode = selectedModes[0]
    }
    
    /// Determine status by fraction of amount spend from the allocated budget amount.
    mutating func updateBudgetStatus() {
        switch(totalMonthlySpend/budgetAmount) {
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

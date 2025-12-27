//
//  MockBudget.swift
//  KartStopper
//
//  Created by Ashish Brahma on 27/12/25.
//
//  The protocol which defines requirements for a Budget model.

import Foundation

protocol BudgetProtocol {
    /// Total amount spent.
    var totalMonthlySpend: Double { get set }
    
    /// Amount allocated for monthly budget.
    var budgetAmount: Double { get set }
    
    /// Difficulty mode used for budget monitoring.
    var budgetMode: Mode { get set }
    
    /// Flag to lock budget for editing.
    var isLocked: Bool { get set }
    
    /// Status indicator of budget.
    var status: Status { get set }
    
    /// Allow budget edits on the beginning of each month.
    mutating func updateBudgetLock(day: Int)
    
    /// Read preferences saved by user.
    mutating func updateBudgetSettings()
    
    /// Determine status by fraction of amount spend from the allocated budget amount.
    mutating func updateBudgetStatus()
}

/// Difficulty levels to determine strictness of monitoring.
enum Mode: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id : String {
        UUID().uuidString
    }
}

/// Categories to grade expenditure.
enum Status: String, CaseIterable, Identifiable {
    case positive = "PositiveStatus"
    case neutral = "NeutralStatus"
    case negative = "NegativeStatus"
    case unassigned = "UnassignedStatus"
    
    var id : String {
        UUID().uuidString
    }
}

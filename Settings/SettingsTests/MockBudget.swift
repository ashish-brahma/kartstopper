//
//  MockBudget.swift
//  KartStopper
//
//  Created by Ashish Brahma on 27/12/25.
//
//  A structure which sets up the mock budget cases for testing Budget model.

import Foundation

struct MockBudget: BudgetProtocol {
    var totalMonthlySpend: Double
    
    var budgetAmount: Double
    
    var budgetMode: Mode
    
    var isLocked: Bool
    
    var status: Status
    
    mutating func updateBudgetLock(day: Int) {
        isLocked = true
    }
    
    mutating func updateBudgetSettings() {
        budgetMode = .medium
    }
    
    mutating func updateBudgetStatus() {}
}


extension MockBudget {
    static var positive: Budget {
        .init(totalMonthlySpend: 1200.00,
              budgetAmount: 5500.00,
              status: .positive
        )
    }
    
    static var neutral: Budget {
        .init(totalMonthlySpend: 3000.00,
              budgetAmount: 5500.00,
              status: .neutral
        )
    }
    
    static var negative: Budget {
        .init(totalMonthlySpend: 5000.00,
              budgetAmount: 5500.00,
              status: .negative
        )
    }
}

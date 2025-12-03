//
//  BudgetTests.swift
//  KartStopper
//
//  Created by Ashish Brahma on 03/12/25.
//
//  Tests that validate business logic of Budget model.

import Testing
@testable import KartStopper

@MainActor
struct BudgetTests {
    let cases = [Budget.positive, Budget.neutral]
    
    @Test("Status correctness", arguments: 0...1)
    mutating func statusUpdatesByAmountSpent(_ index: Int) throws {
        var budget = cases[index]
        budget.totalMonthlySpend = 0.9 * budget.budgetAmount
        budget.updateBudgetStatus()
        #expect(budget.status == .negative)
    }
    
    @Test("Editing is locked")
    mutating func budgetAmountLocked() throws {
        var budget = Budget()
        budget.updateBudgetLock(day: 2)
        #expect(budget.isLocked == true)
        
        let viewModel = ViewModel(budget: Budget(),
                                  hasOnboarded: true)
        viewModel.budget.updateBudgetLock()
        #expect(viewModel.budget.isLocked == true)
    }
    
    @Test("Editing is unlocked")
    mutating func budgetAmountUnLocked() throws {
        var budget = Budget()
        budget.updateBudgetLock(day: 1)
        #expect(budget.isLocked == false)
    }

}

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
    var budget = Budget()
    
    let cases: [Budget] = [
        MockBudget.positive,
        MockBudget.neutral,
        MockBudget.negative
    ]
    
    @Test("Status correctness", arguments: 0...2)
    mutating func monthlySpendUpdatesBudgetStatus(_ index: Int) throws {
        budget.totalMonthlySpend = (budget.neutralCutOff + 1) * cases[index].budgetAmount
        budget.updateBudgetStatus()
        
        #expect(budget.status == .negative, "When total monthly amount spent out of the allocated budget exceeds neutral cut-off ratio, a negative status is expected.")
    }
    
    @Test("Editing is locked")
    mutating func budgetAmountLocked() throws {
        // Case 1: Day of month is not 1.
        budget.updateBudgetLock(day: 2)
        
        #expect(budget.isLocked == true, "Budget is locked for editing if the day of month is other than 1.")
        
        // Case 2: Onboarding of the user is complete.
        let viewModel = ViewModel(budget: Budget(),
                                  hasOnboarded: true)
        
        viewModel.budget.updateBudgetLock()
        
        #expect(viewModel.budget.isLocked == true, "Budget is locked for editing when onboarding has completed.")
    }
    
    @Test("Mode calibrates status",
          arguments: zip(Mode.allCases, [false, true, true]))
    mutating func budgetModeUpdatesRatioCutOffs(
        mode: Mode,
        isTrue: Bool
    ) throws {
        budget.budgetAmount = MockBudget.negative.budgetAmount
        budget.totalMonthlySpend = MockBudget.negative.totalMonthlySpend
        
        budget.budgetMode = mode
        budget.updateBudgetStatus()
        
        let negativeState = (budget.status == .negative)
        #expect(negativeState == isTrue, "Easy mode has a higher cut-off for negative status.")
    }
}

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
    
    @Test("Onboarding completeness")
    mutating func requireBothBudgetAmountAndMode() throws {
        // Case 1: Mode has not been set.
        budget.budgetAmount = MockBudget.positive.budgetAmount
        budget.budgetMode = nil
        
        let viewModel = ViewModel(budget: budget,
                                  hasOnboarded: false)
        
        viewModel.validateOnboarding()
        viewModel.updateOnboardingState()
        
        #expect(viewModel.hasOnboarded == false, "Onboarding is incomplete if budget mode has not been set up.")
        
        // Case 2: Amount has not been set.
        viewModel.budget.budgetAmount = nil
        viewModel.budget.budgetMode = .medium
        
        viewModel.validateOnboarding()
        viewModel.updateOnboardingState()
        
        #expect(viewModel.hasOnboarded == false, "Onboarding is incomplete if budget amount has not been set up.")
    }
    
    @Test("Editing is locked")
    mutating func budgetAmountLocked() throws {
        // Case 1: Day of month is not 1.
        budget.updateBudgetLock(day: 2)
        
        #expect(budget.isLocked == true, "Budget is locked for editing if the day of month is other than 1.")
        
        // Case 2: Onboarding of the user is complete.
        let viewModel = ViewModel(budget: budget,
                                  hasOnboarded: true)
        
        viewModel.budget.updateBudgetLock()
        
        #expect(viewModel.budget.isLocked == true, "Budget is locked for editing when onboarding has completed.")
    }
    
    @Test("Mode calibrates status",
          arguments: zip(BudgetMode.allCases, [false, true, true]))
    mutating func budgetModeUpdatesRatioCutOffs(
        mode: BudgetMode,
        truthValue: Bool
    ) throws {
        budget.budgetAmount = MockBudget.negative.budgetAmount
        budget.totalMonthlySpend = MockBudget.negative.totalMonthlySpend
        
        budget.budgetMode = mode
        budget.updateBudgetStatus()
        
        let negativeState = (budget.status == .negative)
        #expect(negativeState == truthValue, "Easy mode has a higher cut-off for negative status.")
    }
    
    @Test("Status correctness", arguments: 0...2)
    mutating func monthlySpendUpdatesBudgetStatus(_ index: Int) throws {
        let amount = try #require(cases[index].budgetAmount)
        let mode = try #require(cases[index].budgetMode)
        
        budget.budgetAmount = amount
        budget.budgetMode = mode
        budget.totalMonthlySpend = (budget.neutralCutOff + 1) * amount
        budget.updateBudgetStatus()
        
        #expect(budget.status == .negative, "When total monthly amount spent out of the allocated budget exceeds neutral cut-off ratio, a negative status is expected.")
    }
}

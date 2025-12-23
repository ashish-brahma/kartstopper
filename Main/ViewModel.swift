//
//  ViewModel.swift
//  KartStopper
//
//  Created by Ashish Brahma on 04/11/25.
//
//  A class that configures user interface.

import SwiftUI
import CoreData
internal import Combine

class ViewModel: ObservableObject {
    /// Query term used to conduct cart search.
    @Published var cartQuery = ""
    
    /// Total number of carts.
    @Published var totalCarts: Int = 0
    
    /// Instance of budget
    @Published var budget: Budget
    
    /// Title displayed on home view.
    @Published var dynamicTitle: String = ""
    
    /// Color code used on status card in home view.
    @Published var fontColor: Color = .richBlack
    
    /// Query term used to conduct item search.
    @Published var itemQuery = ""
    
    /// Flag to check if user has onboarded.
    @Published var hasOnboarded: Bool = false
    
    init(
        budget: Budget,
        hasOnboarded: Bool
    ) {
        self.budget = budget
        self.hasOnboarded = hasOnboarded
    }
    
    /// Update dashboard.
    func update(context: NSManagedObjectContext) {
        self.objectWillChange.send()
        
        updateOnboardingState()
        if hasOnboarded {
            budget.updateBudgetSettings()
        }
        
        totalCarts = CDCart.getTotalCarts(context: context)
        budget.totalMonthlySpend = CDCart.getTotalMonthlySpend(context: context)
        
        budget.updateBudgetStatus()
        
        dynamicTitle = setTitle()
        fontColor = setFontColor()
    }
    
    /// Set onboarding state of the user.
    func updateOnboardingState() {
        self.objectWillChange.send()
        hasOnboarded = UserDefaults.standard.bool(forKey: "hasOnboarded")
    }
    
    /// Set dynamic title based on budget status.
    func setTitle() -> String {
        switch(budget.status) {
        case .positive:
            "You're Awesome"
        case .neutral:
            "Slow Down"
        case .negative:
            "You're broke"
        case .unassigned:
            "Welcome"
        }
    }
    
    /// Set font color based on status.
    func setFontColor() -> Color {
        switch(budget.status) {
        case .positive:
            .richBlack
        case .neutral:
            .letterJacket
        case .negative:
            .cowpeas
        case .unassigned:
            .richBlack
        }
    }
}



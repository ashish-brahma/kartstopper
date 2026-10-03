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
    
    /// Query term used to conduct item search.
    @Published var itemQuery = ""
    
    /// Total number of carts.
    @Published var totalCarts: Int = 0
    
    /// Total number of items.
    @Published var totalItems: Int = 0
    
    /// Instance of budget
    @Published var budget: Budget
    
    /// Title displayed on home view.
    @Published var dynamicTitle: String = ""
    
    /// Color code used for fonts on status card in home view.
    @Published var fontColor: Color = .richBlack
    
    /// Color code used for gauge on status card in home view.
    @Published var gaugeColor: Color = .gray700
    
    /// Flag to check if user has onboarded.
    @Published var hasOnboarded: Bool = false
    
    init(
        budget: Budget,
        hasOnboarded: Bool
    ) {
        self.budget = budget
        self.hasOnboarded = hasOnboarded
    }
    
    /// Load preferences.
    func loadPreferences(preferencesModel: PreferencesModel) {
        preferencesModel.objectWillChange.send()
        preferencesModel.loadData()
        self.objectWillChange.send()
        
        if let amount = preferencesModel.budgetAmount {
            budget.budgetAmount = amount
        }
        
        if let mode = preferencesModel.selectedMode {
            budget.budgetMode = mode
        }
    }
    
    /// Update dashboard.
    func update(context: NSManagedObjectContext) {
        self.objectWillChange.send()
        
        if hasOnboarded {
            budget.totalMonthlySpend = CDCart.getTotalMonthlySpend(context: context)
            budget.updateBudgetStatus()
        }
        
        totalCarts = CDCart.getTotalCarts(context: context)
        totalItems = CDItem.getTotalItems(context: context)
        
        dynamicTitle = setTitle()
        fontColor = setFontColor()
        gaugeColor = setGaugeColor()
    }
    
    /// Check if both amount and difficulty mode of budget have been set.
    func validateOnboarding() {
        if budget.budgetAmount != nil
            && budget.budgetMode != nil {
            
            UserDefaults.standard.set(true, forKey: "hasOnboarded")
        }
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
    
    /// Set gauge color based on status.
    func setGaugeColor() -> Color {
        switch(budget.status) {
        case .positive:
                .gray700
        case .neutral:
                .letterJacket
        case .negative:
                .cowpeas
        case .unassigned:
                .richBlack
        }
    }
}



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
    @Published var budget: Budget = Budget()
    
    /// Query term used to conduct item search.
    @Published var itemQuery = ""
    
    /// Flag to check if user has onboarded.
    private(set) var hasOnboarded: Bool = false
    
    init() {
        if hasOnboarded {
            budget.disableBudget = true
        }
    }
    
    /// Update dashboard.
    func update(context: NSManagedObjectContext) {
        totalCarts = CDCart.getTotalCarts(context: context)
        budget.totalMonthlySpend = CDCart.getTotalMonthlySpend(context: context)
    }
}

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
    
    /// Total amount spent.
    @Published var totalMonthlySpend: Double = 0.00
    
    /// Amount allocated for monthly budget.
    @Published var budget: Double = 0.00
    
    /// Difficulty mode used for budget monitoring.
    @Published var budgetMode: String = "Easy"
    
    /// Flag to lock budget for editing.
    @Published var disableBudget: Bool = false
    
    /// Status indicator of budget.
    @Published var status: String = "PositiveStatus"
    
    /// Query term used to conduct item search.
    @Published var itemQuery = ""
    
    /// Flag to check if
    private(set) var hasOnboarded: Bool = false
    
    init() {
        if hasOnboarded {
            disableBudget = true
        }
    }
    
    /// Update dashboard.
    func update(context: NSManagedObjectContext) {
        totalCarts = CDCart.getTotalCarts(context: context)
        totalMonthlySpend = CDCart.getTotalMonthlySpend(context: context)
    }
    
    /// Allow budget edits on the beginning of each month.
    func updateBudgetLock() {
        let date = Calendar.current.component(.day, from: .now)
        if date == 1 {
            disableBudget = false
        }
    }
}

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
    @Published var totalSpend: Double = 0.00
    
    /// Status indicator of budget.
    @Published var status: String = "PositiveStatus"
    
    /// Query term used to conduct item search.
    @Published var itemQuery = ""
    
    /// Update total carts.
    func update(context: NSManagedObjectContext) {
        totalCarts = CDCart.getTotalCarts(context: context)
        totalSpend = CDCart.getTotalSpend(context: context)
    }
}

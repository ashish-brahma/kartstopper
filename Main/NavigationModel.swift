//
//  NavigationModel.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/09/26.
//
//  A class that restores navigation state.

import SwiftUI
internal import Combine

class NavigationModel: ObservableObject, Codable {
    /// Currently selected tab in Tab View.
    @Published var selectedTab: Tabs?
    
    /// Currently selected cart in carts list.
    @Published var selectedCart: CDCart?
    
    /// Array of carts pushed on carts' navigation stack.
    @Published var presentedCarts: [CDCart] = []
    
    /// Array of cards pushed on dashboard's navigation stack.
    @Published var presentedCards: [Card] = []
    
    /// Currently selected time range for Category Details chart.
    @Published var selectedTimeRangeForCategories: TimeRange = .last30days
    
    /// Currently selected time range for Expenditure Details chart.
    @Published var selectedTimeRangeForExpenses: TimeRange = .last7days
    
    /// Type that enumerates keys used for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case selectedTab
        case cartPathIds
        case cardPathIds
        case timeRangeCategories
        case timeRangeExpenses
    }
    
    /// Encode all values using coding keys and store them.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedTab, forKey: .selectedTab)
        try container.encode(presentedCarts.map(\.id), forKey: .cartPathIds)
        try container.encode(presentedCards.map(\.id), forKey: .cardPathIds)
        try container.encode(selectedTimeRangeForCategories.rawValue, forKey: .timeRangeCategories)
        try container.encode(selectedTimeRangeForExpenses.rawValue, forKey: .timeRangeExpenses)
    }
    
    init() {}
    
    /// Decode all values using coding keys and load them.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.selectedTab = try container.decodeIfPresent(Tabs.self, forKey: .selectedTab)
        
        let cartPathIds = try container.decode([CDCart.ID].self, forKey: .cartPathIds)
        self.presentedCarts = CDCart.getCarts(by: cartPathIds)
        
        let cardPathIds = try container.decode([Card.ID].self, forKey: .cardPathIds)
        self.presentedCards = cardPathIds.compactMap { Card.allCases[$0] }
        
        let timeRangeCategories = try container.decode(TimeInterval.self, forKey: .timeRangeCategories)
        self.selectedTimeRangeForCategories = TimeRange.allCases.first {
            $0.rawValue == timeRangeCategories
        } ?? .last30days
        
        let timeRangeExpenses = try container.decode(TimeInterval.self, forKey: .timeRangeExpenses)
        self.selectedTimeRangeForExpenses = TimeRange.allCases.first {
            $0.rawValue == timeRangeExpenses
        } ?? .last7days
    }
    
    /// Persisted navigation data in JSON format.
    var jsonData: Data? {
        get {
            try? JSONEncoder().encode(self)
        }
        set {
            guard let data = newValue,
                  let model = try? JSONDecoder().decode(NavigationModel.self, from: data)
            else { return }
            self.selectedTab = model.selectedTab
            self.presentedCarts = model.presentedCarts
            self.presentedCards = model.presentedCards
            self.selectedTimeRangeForCategories = model.selectedTimeRangeForCategories
            self.selectedTimeRangeForExpenses = model.selectedTimeRangeForExpenses
        }
    }
    
    /// An AsyncPublisher which is used to stream navigation data for capture.
    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }
}

/// Type that manages tab data in the root Tab View.
enum Tabs: Int, Hashable, CaseIterable, Identifiable, Codable {
    case home
    case track
    case manage
    
    var id: Int { rawValue }
    
    var localizedName: LocalizedStringKey {
        switch self {
        case .home:
            return "Home"
        case .track:
            return "Track"
        case .manage:
            return "Manage"
        }
    }
    
    var symbol: String {
        switch self {
        case .home:
            return "house"
        case .track:
            return "chart.bar.xaxis.ascending.badge.clock"
        case .manage:
            return "book.and.wrench"
        }
    }
}

/// Type that manages card data in dashboard.
enum Card: Int, Hashable, CaseIterable, Identifiable, Codable {
    case expenses
    case categories
    
    var id: Int { rawValue }
}

/// Type that manages time range data for time range picker in charts.
enum TimeRange: TimeInterval, Hashable, CaseIterable, Codable  {
    case last7days = 7
    case last30days = 30
    case last365days = 365
}

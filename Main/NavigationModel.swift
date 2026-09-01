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
    /// Currently selected tab in TabView
    @Published var selectedTab: Tabs?
    
    /// Type that enumerates keys used for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case selectedTab
    }
    
    /// Encode all values using coding keys and store them.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(selectedTab, forKey: .selectedTab)
    }
    
    init() {}
    
    /// Decode all values using coding keys and load them.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.selectedTab = try container.decodeIfPresent(Tabs.self, forKey: .selectedTab)
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
        }
    }
    
    /// An AsyncPublisher which is used to stream navigation data for capture.
    var objectWillChangeSequence: AsyncPublisher<Publishers.Buffer<ObservableObjectPublisher>> {
        objectWillChange
            .buffer(size: 1, prefetch: .byRequest, whenFull: .dropOldest)
            .values
    }
}

/// Type that manages tab data in the root TabView.
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

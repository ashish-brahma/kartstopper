//
//  Preferences.swift
//  KartStopper
//
//  Created by Ashish Brahma on 24/09/26.
//
//  A class that persists user preferences.

import Foundation
internal import Combine
internal import OSLog

class PreferencesModel: ObservableObject, Codable {
    /// Currently set budget amount.
    @Published var budgetAmount: Double?
    
    /// Currently selected budget mode.
    @Published var selectedMode: BudgetMode?
    
    let logger = Logger(subsystem: "com.goldendamsel.kartstopper", category: "preferences")
    
    /// Type that enumerates keys used for encoding and decoding.
    enum CodingKeys: String, CodingKey {
        case budgetAmount
        case budgetMode
    }
    
    /// Encode all values using coding keys and store them.
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(budgetAmount, forKey: .budgetAmount)
        try container.encodeIfPresent(selectedMode, forKey: .budgetMode)
    }
    
    init() {}
    
    /// Decode all values using coding keys and load them.
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.budgetAmount = try container.decodeIfPresent(Double.self, forKey: .budgetAmount)
        self.selectedMode = try container.decodeIfPresent(BudgetMode.self, forKey: .budgetMode)
    }
    
    /// Persisted navigation data in .plist format.
    var data: Data? {
        get {
            try? PropertyListEncoder().encode(self)
        }
        set {
            guard let data = newValue,
                  let model = try? PropertyListDecoder().decode(PreferencesModel.self, from: data)
            else { return }
            self.budgetAmount = model.budgetAmount
            self.selectedMode = model.selectedMode
        }
    }
    
    /// Save data with complete file protection.
    /// Data is accessible only when device is unlocked.
    func saveData() {
        do {
            try data?.write(to: Constants.Manage.preferencesFilePath,
                                options: .completeFileProtection)
        } catch {
            logger.error("Failed to save preferences. \(error.localizedDescription)")
        }
    }
    
    /// Load persisted data.
    func loadData() {
        do {
            data = try Data(contentsOf: Constants.Manage.preferencesFilePath)
        } catch {
            logger.error("Failed to load preferences. \(error.localizedDescription)")
        }
    }
}

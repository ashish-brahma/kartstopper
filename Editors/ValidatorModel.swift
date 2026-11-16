//
//  ValidatorModel.swift
//  KartStopper
//
//  Created by Ashish Brahma on 13/11/26.
//
//  A class the validates an editor's input data.

import CoreData
internal import Combine
internal import OSLog

class ValidatorModel: ObservableObject {
    /// Name of the item being validated.
    @Published var itemName = ""
    
    /// Name of the cart being validated.
    @Published var cartName = ""
    
    /// Error caused by invalid input.
    @Published var error: ValidationError?
    
    let logger = Logger(subsystem: "com.goldendamsel.kartstopper", category: "validation")
    
    /// Checks if the new inputs for the item being edited are valid.
    func validateItem(context: NSManagedObjectContext) throws {
        if itemName.isEmpty {
            throw ValidationError.nameIsEmpty
        }
        
        let trimmedName = itemName.trimSpaces()
        if !trimmedName.hasValidCharacters(from: .validNameSet) {
            throw ValidationError.containsInvalidCharacters
        }
        
        let existingItemCount = CDItem.findItems(
            by: trimmedName,
            in: cartName,
            context: context
        )
        
        if existingItemCount > 0 {
            throw ValidationError.itemExists
        }
    }
    
    /// Remove any stored values and set to defaults.
    func reset() {
        itemName = ""
        cartName = ""
        error = nil
    }
}

/// Type that manages errors caused by invalid input in editors.
enum ValidationError: Error, Hashable {
    case nameIsEmpty
    case containsInvalidCharacters
    case itemExists
    
    var message: String {
        switch self {
        case .nameIsEmpty:
            "Enter a valid name."
        case .containsInvalidCharacters:
            "Name must contain alphabets(A-Z), numbers(0-9), and spaces only."
        case .itemExists:
            "Item may already exist."
        }
    }
}

extension String {
    /// Trims whitespaces at beginning and end of the `String`.
    func trimSpaces() -> String {
        self.trimmingCharacters(in: .whitespaces)
    }
    
    /// Returns `true` if `String` has valid characters.
    func hasValidCharacters(from set: CharacterSet) -> Bool {
        CharacterSet(charactersIn: self).isSubset(of: set)
    }
}

extension CharacterSet {
    static let validNameSet = CharacterSet.alphanumerics.union(.whitespaces)
}

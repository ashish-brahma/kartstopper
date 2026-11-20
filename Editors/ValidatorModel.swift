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
    func validateItem(
        editorKind: EditorKind,
        context: NSManagedObjectContext
    ) throws {
        if itemName.isEmpty {
            throw ValidationError.nameIsEmpty
        }
        
        let trimmedName = itemName.trimmed
        if !trimmedName.hasValidCharacters(from: .validNameSet) {
            throw ValidationError.containsInvalidCharacters
        }
        
        let existingItemCount = CDItem.findItems(
            by: trimmedName,
            in: cartName,
            context: context
        )
        
        if existingItemCount > 0 {
            throw ValidationError.itemExists(editorKind: editorKind)
        }
    }
    
    /// Checks if the new inputs for the cart being edited are valid.
    func validateCart(
        editorKind: EditorKind,
        context: NSManagedObjectContext
    ) throws {
        if cartName.isEmpty {
            throw ValidationError.nameIsEmpty
        }
        
        let trimmedName = cartName.trimmed
        if !trimmedName.hasValidCharacters(from: .validNameSet) {
            throw ValidationError.containsInvalidCharacters
        }
        
        let existingCartCount = CDCart.findCarts(
            by: trimmedName,
            context: context
        )
        
        if existingCartCount > 0 {
            throw ValidationError.cartExists(editorKind: editorKind)
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
    case itemExists(editorKind: EditorKind)
    case cartExists(editorKind: EditorKind)
    
    /// String that describes the input validation error.
    var message: String {
        switch self {
        case .nameIsEmpty:
            "Enter a valid name."
        case .containsInvalidCharacters:
            "Name must contain alphabets(A-Z), numbers(0-9), spaces and punctutations &()-:#, only."
        case .itemExists(let editorKind):
            existenceMessage(of: "Item", for: editorKind)
        case .cartExists(let editorKind):
            existenceMessage(of: "Cart", for: editorKind)
        }
    }
    
    /// Create appropriate message about an entity's existence
    /// based on entity being edited and the edit action being performed.
    func existenceMessage(
        of entity: String,
        for editorKind: EditorKind
    ) -> String {
        editorKind == .edit ? "\(entity) may already exist or name entered is same as before." : "\(entity) already exists."
    }
}

/// Type that defines the kind of editor based on the edit action being performed.
enum EditorKind: Int, Hashable, Identifiable {
    case add
    case edit
    
    var id: Int { rawValue }
}

extension String {
    /// Trims whitespaces  and punctuations at beginning and end of the `String`.
    var trimmed: String {
        self.trimSpaces().trimPunctuations()
    }
    
    /// Trims whitespaces at beginning and end of the `String`.
    func trimSpaces() -> String {
        self.trimmingCharacters(in: .whitespaces)
    }
    
    /// Trims punctuations at beginning and end of the `String`.
    func trimPunctuations() -> String {
        self.trimmingCharacters(in: .punctuationCharacters)
    }
    
    /// Returns `true` if `String` has valid characters.
    func hasValidCharacters(from set: CharacterSet) -> Bool {
        CharacterSet(charactersIn: self).isSubset(of: set)
    }
}

extension CharacterSet {
    static let allowedPunctutations = CharacterSet(charactersIn: "&()-:#,")
    static let validNameSet = CharacterSet.alphanumerics.union(.whitespaces).union(.allowedPunctutations)
}

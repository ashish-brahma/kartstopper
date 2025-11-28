//
//  CDItem+Extension.swift
//  KartStopper
//
//  Created by Ashish Brahma on 02/10/25.
//
//  The model class of items.

import SwiftUI
import CoreData

extension CDItem {
    var displayName: String {
        guard let name, !name.isEmpty
        else { return "Unknown item" }
        return name
    }
    
    var displayNotes: String {
        guard let notes, !notes.isEmpty
        else { return "" }
        return notes
    }
    
    var displayDate: String {
        guard let timestamp, !timestamp.formatted().isEmpty
        else { return "Undated" }
        return timestamp.formatted(Date.customStyle)
    }
}

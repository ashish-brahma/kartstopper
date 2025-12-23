//
//  Design.swift
//  KartStopper
//
//  Created by Ashish Brahma on 02/11/25.
//
//  Design system used across views.

import SwiftUI

enum Design {
    static let itemNameFontSize = CGFloat(16)
    static let itemCountFontSize = CGFloat(36)
    static let contentUnavailableImageFontSize = CGFloat(36)
    
    static let descriptionFieldLineLimit = 5
    static let descriptionFieldHeight = CGFloat(150.0)
    static let notesMinScaleFactor = 0.6
    
    static let avatarCornerRadius = CGFloat(8)
    static let avatarTextFontSize = CGFloat(48)
    static let avatarDetailCornerRadius = CGFloat(41)
    static let avatarDetailTextFontSize = CGFloat(144)
    
    static let buttonShadowRadius = CGFloat(7)
    
    enum Padding {
        static let vertical = CGFloat(4)
        static let horizontal = CGFloat(4)
        static let standard = CGFloat(8)
        static let leading = CGFloat(16)
        static let trailing = CGFloat(16)
        static let top = CGFloat(8)
        static let bottom = CGFloat(8)
    }
    
    enum Fonts {
        static let largeNumber = "NewYorkLarge-Regular"
        static let italicCaption = "NewYorkMedium-SemiboldItalic"
    }
}

// Design Constants
extension Color {
    static let reversal = Color("Gray500")
    static let affirmative = Color("Gray700")
    static let edit = Color("Sanskrit")
    static let info = Color("TurkishAqua")
}


// Random Number Generator
struct SeededRandomGenerator: RandomNumberGenerator {
    init(seed: Int) {
        srand48(seed)
    }
    
    func next() -> UInt64 {
        UInt64(drand48() * Double(UInt64.max))
    }
}

// Random Color Generator
extension Color {
    static var random: Color {
        var generator: RandomNumberGenerator = SystemRandomNumberGenerator()
        return random(using: &generator)
    }
    
    static func random(using generator: inout RandomNumberGenerator) -> Color {
        let red = Double.random(in: 0..<1, using: &generator)
        let green = Double.random(in: 0..<1, using: &generator)
        let blue = Double.random(in: 0..<1, using: &generator)
        return Color(red: red, green: green, blue: blue)
    }
}

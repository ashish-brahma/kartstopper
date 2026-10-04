//
//  Static.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/12/25.
//
//  Static text used in views.

import Foundation

enum Constants {
    enum Manage {
        static let monthlyBudgetWarning = "Review the amount before submission. This field remains disabled for editing for the rest of the month."
        
        static let faqURL = "https://kartstopper.netlify.app/support/"
        static let privacyURL = "https://kartstopper.netlify.app/privacy-policy/"
        static let contactURL = "mailto:kartstopper@outlook.com"
        static let developerURL = "https://ashish-brahma.github.io/portfolio/"
        static let repositoryURL = "https://github.com/ashish-brahma/kartstopper"
        
        static let preferencesFilePath = FileManager.documentsDirectory.appending(path: "Preferences")
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        return paths[0]
    }
}

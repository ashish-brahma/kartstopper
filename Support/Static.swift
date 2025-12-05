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
        static let monthlyBudgetFooter = "Budget limit is unlocked for modification on the first day of each month. Tap on the field to use keyboard."
        
        static let budgetModeFooter = "Budget mode sets the level of strictness with which expenses are monitored with respect to budget limit."
        
        static let legalLine1 = "KartStopper is an open-source project hosted on "
        
        static let legalLine2 = " and distributed under a "
        
        static let aboutDeveloperLine1 = "Ashish is currently working as an open-source mobile app developer for "
        
        static let aboutDeveloperLine2 = ". He has previously worked in Analytics and Data Science before embarking on his development journey. When not coding, he likes to look after his plants."
        
        static let appName = "KartStopper"
        static let host = "GitHub"
        static let license = "BSD 3-Clause License"
        
        static let developerName = PersonNameComponents(
            givenName: "Ashish",
            familyName: "Brahma"
        )
        
        static let faqURL = "https://kartstopper.netlify.app/support/"
        static let privacyURL = "https://kartstopper.netlify.app/legal-notice/"
        static let contactURL = "mailto:kartstopper@outlook.com"
        static let developerURL = "https://ashish-brahma.github.io/portfolio/"
        static let repositoryURL = "https://github.com/ashish-brahma/kartstopper"
    }
}

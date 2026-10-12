//
//  Static.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/12/25.
//
//  Static text used in views.

import Foundation

enum Constants {
    enum Setup {
        static let purpose = "Budget amount would be used to gauge monthly expenditure."
    }
    
    enum Manage {
        static let preferencesFilePath = FileManager.documentsDirectory.appending(path: "Preferences")
        
        static let monthlyBudgetWarning = "Review the amount before submission. This field remains disabled for editing for the rest of the month."
        
        enum Legal: Int, CaseIterable, Identifiable {
            case privacy
            case terms
            
            var urlString: String {
                switch self {
                case .privacy:
                    "https://kartstopper.netlify.app/app-privacy/"
                case .terms:
                    "https://kartstopper.netlify.app/terms/"
                }
            }
            
            var title: String {
                switch self {
                case .privacy:
                    "Privacy Notice"
                case .terms:
                    "Terms of Use"
                }
            }
            
            var id: Int { rawValue }
        }
        
        enum Help: Int, CaseIterable, Identifiable {
            case support
            case contact
            
            var urlString: String {
                switch self {
                case .support:
                    "https://kartstopper.netlify.app/support/"
                case .contact:
                    "mailto:kartstopper@outlook.com"
                }
            }
            
            var title: String {
                switch self {
                case .support:
                    "Frequently Asked Questions"
                case .contact:
                    "Send us an email"
                }
            }
            
            var id: Int { rawValue }
        }
        
        enum Social: Int, CaseIterable, Identifiable {
            case home
            case repository
            case linkedIn
            
            var urlString: String {
                switch self {
                case .home:
                    "https://kartstopper.netlify.app/"
                case .repository:
                    "https://github.com/ashish-brahma/kartstopper"
                case .linkedIn:
                    "https://www.linkedin.com/company/kartstopper"
                }
            }
            
            var title: String {
                switch self {
                case .home:
                    "Visit our website"
                case .repository:
                    "KartStopper on GitHub"
                case .linkedIn:
                    "KartStopper on LinkedIn"
                }
            }
            
            var id: Int { rawValue }
        }
        
        static let developerURL = "https://ashish-brahma.github.io/portfolio/"
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

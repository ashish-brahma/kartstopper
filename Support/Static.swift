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
        static let purpose = "Budget preferences would be used to gauge monthly expenditure."
    }
    
    enum Manage {
        static let preferencesFilePath = FileManager.documentsDirectory.appending(path: "Preferences")
        
        static let monthlyBudgetWarning = "Review the amount before submission. This field remains disabled for editing for the rest of the month."
        
        enum InformationLinks: Int, CaseIterable, Identifiable {
            case legal
            case help
            case feedback
            case social
            
            var externalLinks: [ExternalLink] {
                switch self {
                case .legal:
                    Legal.allCases
                case .help:
                    Help.allCases
                case .feedback:
                    Feedback.allCases
                case .social:
                    Social.allCases
                }
            }
            
            var groupTitle: String {
                switch self {
                case .legal:
                    "Legal"
                case .help:
                    "Help & Support"
                case .feedback:
                    "Feedback"
                case .social:
                    "Follow us"
                }
            }
            
            var id: Int { rawValue }
            
            enum Legal: Int, CaseIterable, Identifiable, ExternalLink {
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
                
                var labelName: String {
                    switch self {
                    case .privacy:
                        "Privacy Notice"
                    case .terms:
                        "Terms of Use"
                    }
                }
                
                var symbol: String {
                    switch self {
                    case .privacy:
                        "eye.fill"
                    case .terms:
                        "text.badge.checkmark"
                    }
                }
                
                var id: Int { rawValue }
            }
            
            enum Help: Int, CaseIterable, Identifiable, ExternalLink {
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
                
                var labelName: String {
                    switch self {
                    case .support:
                        "Frequently Asked Questions"
                    case .contact:
                        "Send us an email"
                    }
                }
                
                var symbol: String {
                    switch self {
                    case .support:
                        "questionmark.circle.fill"
                    case .contact:
                        "paperplane.fill"
                    }
                }
                
                var id: Int { rawValue }
            }
            
            enum Feedback: Int, CaseIterable, Identifiable, ExternalLink {
                case storePage
                
                var urlString: String {
                    switch self {
                    case .storePage:
                        "https://apps.apple.com/us/app/kartstopper/id6813073115?itscg=30200&itsct=apps_box_link&mttnsubad=6813073115"
                    }
                }
                
                var labelName: String {
                    switch self {
                    case .storePage:
                        "Leave us a review"
                    }
                }
                
                var symbol: String {
                    switch self {
                    case .storePage:
                        "star.fill"
                    }
                }
                
                var id: Int { rawValue }
            }
            
            enum Social: Int, CaseIterable, Identifiable, ExternalLink {
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
                
                var labelName: String {
                    switch self {
                    case .home:
                        "Visit our homepage"
                    case .repository:
                        "KartStopper on GitHub"
                    case .linkedIn:
                        "KartStopper on LinkedIn"
                    }
                }
                
                var symbol: String {
                    switch self {
                    case .home:
                        "laptopcomputer"
                    case .repository:
                        "chevron.left.forwardslash.chevron.right"
                    case .linkedIn:
                        "person.2.fill"
                    }
                }
                
                var id: Int { rawValue }
            }
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

/// A protocol which defines requisites for an external link.
protocol ExternalLink {
    var urlString: String { get }
    var labelName: String { get }
    var symbol: String { get }
    var id: Int { get }
}

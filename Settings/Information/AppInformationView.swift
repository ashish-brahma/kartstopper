//
//  AppInformationView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 10/10/26.
//
//  A SwiftUI view that displays app information.

import SwiftUI

struct AppInformationView: View {
    var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var icon: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
    
    let copyright: Image = Image(systemName: "c.circle")
    
    var body: some View {
        GeometryReader { reader in
            List {
                Section("KartStopper") {
                    LazyVGrid(columns: [GridItem(.flexible())]) {
                        VStack(alignment: .center) {
                            if let icon = icon {
                                Image(uiImage: icon)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: reader.size.height/6)
                                    .clipShape(RoundedRectangle(cornerRadius: Design.iconRadius))
                                    .padding(.bottom, Design.Padding.bottom)
                            }
                            
                            Text("KartStopper")
                                .font(.headline)
                            
                            Text("Version \(version)")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                                .padding(.bottom, Design.Padding.bottom)
                            
                            Text("""
                            Create lists with price and notes.
                            Track how you spend your monthly budget and more.   
                            """)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(width: reader.size.width/2)
                            .padding(.bottom, Design.Padding.bottom)
                            
                            Text("Copyright \(copyright) 2026 Ashish Brahma")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .labelStyle(.titleAndIcon)
                        }
                        .padding(Design.Padding.standard)
                    }
                }
                
                Section("Help & Support") {
                    LinkButton(urlString: Constants.Manage.faqURL,
                               title: "Frequently Asked Questions")
                    
                    LinkButton(urlString: Constants.Manage.privacyURL,
                               title: "Privacy Policy")
                    
                    LinkButton(urlString: Constants.Manage.contactURL,
                               title: "Send us an email")
                }
                
                Section("Follow us") {
                    LinkButton(urlString: Constants.Manage.homeURL,
                               title: "Visit our website")
                    
                    LinkButton(urlString: Constants.Manage.linkedInURL,
                               title: "KartStopper on LinkedIn")
                    
                    LinkButton(urlString: Constants.Manage.repositoryURL,
                               title: "KartStopper on GitHub")
                }
            }
            .navigationTitle("About KartStopper")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        AppInformationView()
    }
}

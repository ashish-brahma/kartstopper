//
//  AppInformationView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 10/10/26.
//
//  A SwiftUI view that displays app information.

import SwiftUI

struct AppInformationView: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var icon: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
    
    private let copyright: Image = Image(systemName: "c.circle")
    
    var body: some View {
        GeometryReader { reader in
            List {
                Section {
                    heroView(proxy: reader)
                }
                .listRowBackground(Color.clear)
                
                Section("Help & Support") {
                    ForEach(Constants.Manage.Help.allCases) { link in
                        LinkButton(urlString: link.urlString,
                                   title: link.title)
                    }
                }
                
                Section("Legal") {
                    ForEach(Constants.Manage.Legal.allCases) { link in
                        LinkButton(urlString: link.urlString,
                                   title: link.title)
                    }
                }
                
                Section("Follow us") {
                    ForEach(Constants.Manage.Social.allCases) { link in
                        LinkButton(urlString: link.urlString,
                                   title: link.title)
                    }
                }
            }
            .navigationTitle("About KartStopper")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func heroView(proxy: GeometryProxy) -> some View {
        LazyVGrid(columns: [GridItem(.flexible())]) {
            VStack(alignment: .center) {
                if let icon = icon {
                    appIcon(icon: icon,
                            proxy: proxy)
                }
                
                Text("KartStopper")
                    .font(.headline)
                
                Text("Version \(version)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, Design.Padding.bottom)
                
                Text("Create shopping lists with price and notes.\n\nTrack how you spend your monthly budget and more.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .frame(width: proxy.size.width/1.65)
                .padding(.bottom, Design.Padding.bottom)
                
                Text("Copyright \(copyright) 2026 Ashish Brahma")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .labelStyle(.titleAndIcon)
                    .padding(Design.Padding.standard)
            }
        }
    }
    
    private func appIcon(
        icon: UIImage,
        proxy: GeometryProxy
    ) -> some View {
            Image(uiImage: icon)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(height: proxy.size.height/6)
                .clipShape(RoundedRectangle(cornerRadius: Design.iconRadius))
                .padding(.bottom, Design.Padding.bottom)
    }
}

#Preview {
    NavigationStack {
        AppInformationView()
    }
}

//
//  LinkButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 31/08/26.
//
//  A SwiftUI view that displays a web url resource.

import SwiftUI

struct LinkButton: View {
    let url: URL?
    let title: String
    let symbol: String
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button(title, systemImage: symbol) {
            if let url = url {
                openURL(url)
            }
        }
    }
}



#Preview {
    let externalLink = Constants.Manage.InformationLinks.Social.repository
    LinkButton(
        url: URL(string: externalLink.urlString),
        title: externalLink.labelName,
        symbol: externalLink.symbol
    )
}

//
//  LinkButton.swift
//  KartStopper
//
//  Created by Ashish Brahma on 31/08/26.
//
//  A SwiftUI view that displays a web url resource.

import SwiftUI

struct LinkButton: View {
    let urlString: String
    let title: String
    
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        Button {
            if let url = URL(string: urlString) {
                openURL(url)
            }
        } label: {
            Label(title, systemImage: "link")
        }
    }
}



#Preview {
    LinkButton(urlString: Constants.Manage.repositoryURL,
               title: "GitHub")
}

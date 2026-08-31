//
//  DeveloperView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 31/08/26.
//  A SwiftUI view that displays developer information.

import SwiftUI

struct DeveloperView: View {
    var body: some View {
        List {
            Section("Developer") {
                VStack(alignment: .leading) {
                    Text(Constants.Manage.developerName.formatted())
                        .font(.title3.bold())
                        .padding(.bottom, Design.Padding.bottom/2)
                    
                    VStack(alignment: .leading) {
                        Text(Constants.Manage.aboutDeveloperLine1)
                        + Text(Constants.Manage.appName).bold()
                        + Text(Constants.Manage.aboutDeveloperLine2)
                        
                        LinkButton(urlString: Constants.Manage.developerURL,
                                   title: "Personal Website")
                        .padding(.top, Design.Padding.top)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("Developer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DeveloperView()
}

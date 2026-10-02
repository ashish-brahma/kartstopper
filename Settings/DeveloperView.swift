//
//  DeveloperView.swift
//  KartStopper
//
//  Created by Ashish Brahma on 31/08/26.
//  A SwiftUI view that displays developer information.

import SwiftUI

struct DeveloperView: View {
    let appName = Text("KartStopper").bold()
    
    let developerName = PersonNameComponents(
        givenName: "Ashish",
        familyName: "Brahma"
    )
    
    var body: some View {
        List {
            Section("Developer") {
                VStack(alignment: .leading) {
                    Text(developerName.formatted())
                        .font(.title3.bold())
                        .padding(.bottom, Design.Padding.bottom/2)
                    
                    VStack(alignment: .leading) {
                        Text("\(developerName.givenName ?? "") is currently working as a mobile app developer for \(appName), an open source shopping planner app. He has previously worked in Analytics and Data Science before embarking on his development journey. When not coding, he likes to look after his plants.")
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, Design.Padding.bottom)
                
                LinkButton(urlString: Constants.Manage.developerURL,
                           title: "Personal Website")
                .padding(.bottom, Design.Padding.bottom/2)
            }
        }
        .navigationTitle("Developer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DeveloperView()
}

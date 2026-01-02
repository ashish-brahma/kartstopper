//
//  NavigationBar.swift
//  KartStopper
//
//  Created by Ashish Brahma on 01/01/26.
//
//  A SwiftUI view which displays a navigation bar with a custom title.

import SwiftUI

struct NavigationBar: View {
    @ObservedObject var viewModel: ViewModel
    
    @Binding var showPreferences: Bool
    
    let reader: GeometryProxy
    
    var body: some View {
        HStack {
            Text(viewModel.dynamicTitle)
                .font(.title.bold())
                .foregroundStyle(viewModel.fontColor)
                .padding(.leading, Design.Padding.leading/1.4)
            
            Spacer()
            
            SettingsButton(showPreferences: $showPreferences,
                           configuration: .toolbar)
            .padding(Design.Padding.standard)
        }
        .padding(.top, reader.size.height/20)
        .padding(.horizontal, Design.Padding.horizontal)
        .padding(.bottom, -Design.Padding.bottom)
    }
}

#Preview {
    GeometryReader { reader in
        NavigationBar(viewModel: .preview,
                      showPreferences: .constant(false),
                      reader: reader)
    }
}

//
//  View+Extension.swift
//  KartStopper
//
//  Created by Ashish Brahma on 07/10/25.
//
//  Extensions that add convenience methods to Views.

import SwiftUI

// ViewBuilder methods to display views when content is not available.
extension View {
    @ViewBuilder
    static var searchUnavailableView: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView.search
        } else {
            VStack {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
                    .font(.system(size: Design.contentUnavailableImageFontSize,
                                  weight: .medium))
                    .padding(.vertical, Design.Padding.vertical)
                Text("No Results")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .bold()
                Text("Check the spelling or try a new search.")
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
            .frame(alignment: .centerFirstTextBaseline)
        }
    }
    
    @ViewBuilder
    static func unavailableView(label: String, symbolName: String, description: String) -> some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView {
                Label(label, systemImage: symbolName)
            } description: {
                Text(description)
            }
        } else {
            VStack {
                Image(systemName: symbolName)
                    .imageScale(.large)
                    .font(.system(size: Design.contentUnavailableImageFontSize,
                                  weight: .medium))
                    .padding(.vertical, Design.Padding.vertical)
                Text(label)
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .bold()
                Text(description)
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
            .frame(alignment: .center)
        }
    }
}

extension View {
    /// Sets custom color for navigation title.
    @available(iOS 14, *)
    func navigationTitleColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        
        UINavigationBar
            .appearance()
            .titleTextAttributes = [
                .foregroundColor: uiColor
            ]
        
        UINavigationBar
            .appearance()
            .largeTitleTextAttributes = [
                .foregroundColor: uiColor
            ]
        
        return self
    }
}

extension View {
    /// Set currency format for amount.
    @ViewBuilder
    func setCurrency(for amount: Double) -> some View {
        Text(amount
                .formatted(.currency(code: Locale.current.currency?.identifier ?? "USD")))
    }
}


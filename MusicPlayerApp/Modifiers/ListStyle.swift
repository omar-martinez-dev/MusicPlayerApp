//
//  ListStyle.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 1/19/25.
//
import SwiftUI
import Foundation

struct ListStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .contentMargins(.vertical, 0)
            .contentMargins(.horizontal, 0)
    }
}

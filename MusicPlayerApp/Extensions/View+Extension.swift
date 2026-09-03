//
//  View+Extension.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 10/14/24.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func withToast() -> some View {
        modifier(ToastModifier())
    }
}

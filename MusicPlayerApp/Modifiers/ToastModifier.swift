//
//  ToastModifier.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 7/18/25.
//

import Foundation
import SwiftUI

struct ToastModifier: ViewModifier {
    
    @State private var event: AppEvent?
    @State private var dismisstrack: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .environment(\.showToast, ShowToastAction(action: { event in
                withAnimation(.easeInOut) {
                    self.event = event
                }
                
                dismisstrack?.cancel()
                
                let task = DispatchWorkItem {
                    withAnimation(.easeInOut) {
                        self.event = nil
                    }
                }
                
                self.dismisstrack = task
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: task)
            }))
            .overlay(alignment: .top) {
                if let event {
                    EventOverlay(event: event)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 50)
                }
            }
    }
}

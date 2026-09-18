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
    @State private var dismissTask: Task<Void, Never>?
    
    func body(content: Content) -> some View {
        content
            .environment(\.showToast, ShowToastAction(action: { event in
                withAnimation(.easeInOut) {
                    self.event = event
                }
                
                dismissTask?.cancel()
                dismissTask = Task { @MainActor in
                    do {
                        try await Task.sleep(for: .seconds(3))
                    } catch is CancellationError {
                        return
                    } catch {
                        return
                    }

                    withAnimation(.easeInOut) {
                        self.event = nil
                    }
                }
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

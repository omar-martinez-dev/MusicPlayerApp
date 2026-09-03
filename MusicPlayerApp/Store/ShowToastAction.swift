//
//  EventManagerStore.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 6/23/25.
//

import Observation
import SwiftUI

enum AppEvent: Equatable {
    case success(message: String)
    case error(message: String)
    case info(message: String)
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        }
    }
    
    var icon: Image {
        switch self {
        case .success: return Image(systemName: "checkmark.circle")
        case .error: return Image(systemName: "exclamationmark.triangle")
        case .info: return Image(systemName: "info.circle")
        }
    }
    
    var message: String {
        switch self {
        case .success(message: let message), .error(message: let message), .info(message: let message):
            return message
        }
    }
}

struct ShowToastAction {
    typealias Action = (AppEvent) -> Void
    let action: Action
    
    func callAsFunction(_ event: AppEvent) {
        action(event)
    }
}

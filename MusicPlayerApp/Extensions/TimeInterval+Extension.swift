//
//  TimeInterval+Extension.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 10/2/24.
//

import Foundation

extension TimeInterval {
    var formattedTime: String {
        let minute = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minute, seconds)
    }
}

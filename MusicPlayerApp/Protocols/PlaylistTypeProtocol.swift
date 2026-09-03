//
//  PlaylistTypeProtocol.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 11/21/24.
//

import Foundation

protocol PlaylistType: AnyObject {
    var id: UUID { get }
    var title: String { get }
    var trackList: [Track] { get set }
    
    func addTrack(_ track: Track)
    func removeTrack(_ track: Track)
}

//
//  EnvironmentValues+Extension.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/10/24.
//

import SwiftUI

private struct AudioPlayerStoreKey: EnvironmentKey {
    static let defaultValue: AudioPlayerStore = AudioPlayerStore()
}

private struct FileManagerStoreKey: EnvironmentKey {
    static let defaultValue: FileManagerStore = FileManagerStore()
}

private struct StartUpStoreKey: EnvironmentKey {
    static let defaultValue: StartUpStore = try! StartUpStore()
}

extension EnvironmentValues {
    
    @Entry var showToast = ShowToastAction(action: { _ in })
    
    var audioPlayerStore: AudioPlayerStore {
        get { self[AudioPlayerStoreKey.self] }
        set { self[AudioPlayerStoreKey.self] = newValue }
    }
    
    var fileManagerStore: FileManagerStore {
        get { self[FileManagerStoreKey.self] }
        set { self[FileManagerStoreKey.self] = newValue }
    }
    
    var startUpStore: StartUpStore {
        get { self[StartUpStoreKey.self] }
        set { self[StartUpStoreKey.self] = newValue }
    }
}

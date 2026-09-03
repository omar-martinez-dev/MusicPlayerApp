//
//  FileManagerStore.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/29/24.
//

import Foundation
import Observation
import AVFAudio
import AVFoundation

@Observable
class FileManagerStore {
    
    var showToast: ShowToastAction?
    
    @MainActor
    public func saveImportedFile(_ fileURL: URL) async -> Track? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            showToast?(.error(message: "Documents directory not found"))
            return nil
        }
        
        let fileName = fileURL.lastPathComponent
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try fileManager.copyItem(at: fileURL, to: destinationURL)
            
            if let metadata = await extractMetadata(from: destinationURL) {
                let track = Track(
                    id: UUID(),
                    title: metadata.title ?? fileURL.deletingPathExtension().lastPathComponent,
                    artist: metadata.artist ?? "Unknown Artist",
                    album: metadata.album ?? "Unknown Album",
                    duration: metadata.duration ?? 0.0,
                    fileName: fileName,
                    artwork: metadata.artwork
                )
                return track
            } else {
                showToast?(.error(message: "Failed to extract metadata"))
            }
            
        } catch {
            showToast?(.error(message: "Failed to save file to documents directory"))
        }
        return nil
    }

    public func deleteFile(withName fileName: String) {
            let fileManager = FileManager.default
            
            guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                showToast?(.error(message: "Documents directory not found"))
                return
            }
            
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            guard fileManager.fileExists(atPath: fileURL.path) else {
                showToast?(.error(message: "File does not exist at path: \(fileURL.path)"))
                print("File does not exist at path: \(fileURL.path)")
                return
            }
            
            do {
                try fileManager.removeItem(at: fileURL)
                showToast?(.success(message: "Track deleted successfully"))
            } catch {
                showToast?(.error(message: "Failed to delete file: \(error)"))
            }
        }
    
    private func extractMetadata(from url: URL) async -> (title: String?, artist: String?, album: String?, duration: Double?, artwork: Data?)? {
        
        var title: String?
        var artist: String?
        var album: String?
        var duration: Double?
        var artwork: Data?
        
        do {
            let asset = AVAsset(url: url)
            
            for format in try await asset.load(.availableMetadataFormats) {
                let metadata = try await asset.loadMetadata(for: format)
                
                let titleItems = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierTitle)
                title = try await titleItems.first?.load(.stringValue)
                
                let artistItems = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierArtist)
                artist = try await artistItems.first?.load(.stringValue)
                
                let albumItems = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierAlbumName)
                album = try await albumItems.first?.load(.stringValue)
                
                let durationItems = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .id3MetadataTime)
                let durationItem = try await durationItems.first?.load(.numberValue)
                duration = durationItem?.doubleValue
                
                if duration == nil {
                    duration = getAudioDuration(from: url)
                }
                
                let artworkItems = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierArtwork)
                artwork = try await artworkItems.first?.load(.dataValue)
                
            }
        } catch {
            showToast?(.error(message: error.localizedDescription))
        }
        return (title, artist, album, duration, artwork)
    }
    
    private func getAudioDuration(from url: URL) -> Double {
        let audioPlayer = try? AVAudioPlayer(contentsOf: url)
        return audioPlayer?.duration ?? 0.0
    }
}




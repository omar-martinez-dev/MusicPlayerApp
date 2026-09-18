//
//  FileManagerStore.swift
//  MusicPlayerApp
//
//  Created by Omar Martinez on 9/29/24.
//

import Foundation
import Observation
import AVFoundation

@MainActor
@Observable
final class FileManagerStore {
    enum FileError: LocalizedError {
        case documentsDirectoryUnavailable
        case securityScopedResourceUnavailable

        var errorDescription: String? {
            switch self {
            case .documentsDirectoryUnavailable:
                "The app's Documents directory is unavailable."
            case .securityScopedResourceUnavailable:
                "The selected file could not be accessed."
            }
        }
    }

    private struct Metadata: Sendable {
        let title: String?
        let artist: String?
        let album: String?
        let duration: TimeInterval
        let artwork: Data?
    }

    func importTrack(from sourceURL: URL) async throws -> Track {
        guard sourceURL.startAccessingSecurityScopedResource() else {
            throw FileError.securityScopedResourceUnavailable
        }
        defer { sourceURL.stopAccessingSecurityScopedResource() }

        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw FileError.documentsDirectoryUnavailable
        }

        let fileExtension = sourceURL.pathExtension
        let storedFileName = fileExtension.isEmpty
            ? UUID().uuidString
            : "\(UUID().uuidString).\(fileExtension)"
        let destinationURL = documentsDirectory.appending(path: storedFileName)

        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            let metadata = try await Self.extractMetadata(from: destinationURL)

            return Track(
                id: UUID(),
                title: metadata.title ?? sourceURL.deletingPathExtension().lastPathComponent,
                artist: metadata.artist ?? "Unknown Artist",
                album: metadata.album ?? "Unknown Album",
                duration: metadata.duration,
                fileName: storedFileName,
                artwork: metadata.artwork
            )
        } catch {
            try? FileManager.default.removeItem(at: destinationURL)
            throw error
        }
    }

    func deleteFile(withName fileName: String) throws {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw FileError.documentsDirectoryUnavailable
        }

        let fileURL = documentsDirectory.appending(path: fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        try FileManager.default.removeItem(at: fileURL)
    }

    func embeddedArtwork(forFileNamed fileName: String) async throws -> Data? {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            throw FileError.documentsDirectoryUnavailable
        }

        let fileURL = documentsDirectory.appending(path: fileName)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return try await Self.extractMetadata(from: fileURL).artwork
    }

    private nonisolated static func extractMetadata(from url: URL) async throws -> Metadata {
        let asset = AVAsset(url: url)
        let metadata = try await asset.load(.commonMetadata)
        let durationValue = try await asset.load(.duration).seconds

        let titleItem = AVMetadataItem.metadataItems(
            from: metadata,
            filteredByIdentifier: .commonIdentifierTitle
        ).first
        let artistItem = AVMetadataItem.metadataItems(
            from: metadata,
            filteredByIdentifier: .commonIdentifierArtist
        ).first
        let albumItem = AVMetadataItem.metadataItems(
            from: metadata,
            filteredByIdentifier: .commonIdentifierAlbumName
        ).first
        let artworkItem = AVMetadataItem.metadataItems(
            from: metadata,
            filteredByIdentifier: .commonIdentifierArtwork
        ).first

        let title = try await titleItem?.load(.stringValue)
        let artist = try await artistItem?.load(.stringValue)
        let album = try await albumItem?.load(.stringValue)
        let artwork = try await artworkItem?.load(.dataValue)

        return Metadata(
            title: title,
            artist: artist,
            album: album,
            duration: durationValue.isFinite ? durationValue : 0,
            artwork: artwork
        )
    }
}

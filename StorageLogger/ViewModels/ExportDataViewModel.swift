//
//  ExportDataViewModel.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/12/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// A view model responsible for exporting and importing app data,
/// including compression, decompression, and JSON serialization of entries.
class ExportDataViewModel: ObservableObject {
    
    /// The currently exported compressed file containing the JSON data.
    @Published var exportedFile = CompressedFile()
    
    /// A reference to the app's central data store used to access and modify entries.
    var dataStore: DataStore

    /// Initializes a new `ExportDataViewModel` with the given `DataStore`.
    ///
    /// - Parameter dataStore: The shared data store containing entries to export or import.
    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }

    /// Exports the current entries from the data store as a compressed JSON file.
    /// This uses LZFSE compression for efficient storage.
    func exportData() {
        if let jsonString = convertEntriesToJson(entries: dataStore.entries) {
            let data = Data(jsonString.utf8)
            do {
                let compressedData = try (data as NSData).compressed(using: .lzfse)
                exportedFile = CompressedFile(data: compressedData as Data)
            } catch {
                print("Compression failed: \(error)")
            }
        }
    }

    /// Handles the result of a file export operation, logging any errors.
    ///
    /// - Parameter result: The result returned by a file exporter, including a success URL or an error.
    func handleExportResult(_ result: Result<URL, Error>) {
        if case .failure(let error) = result {
            print("Export failed: \(error.localizedDescription)")
        }
    }

    /// Handles the import of previously exported data from a compressed file.
    /// It decompresses and restores entries into the data store.
    ///
    /// - Parameters:
    ///   - result: A result containing an array of file URLs or an error.
    ///   - replace: A flag indicating whether to replace existing entries or merge with them.
    func handleImport(_ result: Result<[URL], Error>, replace: Bool) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            do {
                
                // Load the compressed data from disk
                let compressedData = try Data(contentsOf: fileURL)
                
                // Decompress the data using LZFSE
                let decompressedData = try (compressedData as NSData).decompressed(using: .lzfse)
                
                // Restore entries from the decompressed data
                dataStore.entries = restoreEntries(from: decompressedData as Data, intersection: replace ? nil : dataStore.entries)
            } catch {
                print("Import failed: \(error)")
            }
        case .failure(let error):
            print("Import error: \(error.localizedDescription)")
        }
    }
}

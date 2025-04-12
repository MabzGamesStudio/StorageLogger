//
//  ExportDataViewModel.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/12/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class ExportDataViewModel: ObservableObject {
    @Published var exportedFile = CompressedFile()
    var dataStore: DataStore

    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }

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

    func handleExportResult(_ result: Result<URL, Error>) {
        if case .failure(let error) = result {
            print("Export failed: \(error.localizedDescription)")
        }
    }

    func handleImport(_ result: Result<[URL], Error>, replace: Bool) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            do {
                let compressedData = try Data(contentsOf: fileURL)
                let decompressedData = try (compressedData as NSData).decompressed(using: .lzfse)
                dataStore.entries = restoreEntries(from: decompressedData as Data, intersection: replace ? nil : dataStore.entries)
            } catch {
                print("Import failed: \(error)")
            }

        case .failure(let error):
            print("Import error: \(error.localizedDescription)")
        }
    }
}

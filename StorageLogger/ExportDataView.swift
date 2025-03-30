//
//  ExportDataView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/23/25.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers
import Foundation

struct ExportDataView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var dataExport = CompressedFile()
    @State private var showFileExplorer = false
    @State private var showFileImporterCombine = false
    @State private var showFileImporterReplace = false
    @ObservedObject var dataStore = DataStore()
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    func exportDataStoreToJSON() -> URL? {
        let fileManager = FileManager.default
        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try jsonEncoder.encode(dataStore.entries) // Encode entries to JSON
            let fileURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("entries_backup.json")
            
            try jsonData.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to export data: \(error)")
            return nil
        }
    }
    
    var body: some View {
        VStack {
            Text("Export Data")
                .font(.title)
                .padding()

            Button(action: {
                let data: Data
                if let jsonString = convertEntriesToJson(entries: dataStore.entries) {
                    data = Data(jsonString.utf8)
                } else {
                    data = Data("".utf8)
                }
                do {
                    let compressedData = try (data as NSData).compressed(using: .lzfse)
                    print(compressedData)
                    dataExport = CompressedFile(data: compressedData as Data)
                } catch {
                    print(error.localizedDescription)
                }
                showFileExplorer = true
            }) {
                Text("Download")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .fileExporter(isPresented: $showFileExplorer, document: dataExport, contentType: .data) { result in
                switch result {
                    case .success(let url):
                        print("Saved to \(url)")
                    case .failure(let error):
                        print(error.localizedDescription)
                }
            }
            .padding()
            Text("Import Data")
                .font(.title)
                .padding()

            Button(action: {
                showFileImporterCombine = true
            }) {
                Text("File Upload: Combine")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .fileImporter(
                isPresented: $showFileImporterCombine,
                allowedContentTypes: [.data], // Accepts generic data files
                allowsMultipleSelection: false
            ) { result in
                switch result {
                    case .success(let urls):
                        if let fileURL = urls.first {
                            do {
                                // Read the selected file
                                let compressedData = try Data(contentsOf: fileURL)
                                
                                
                                // Decompress using LZFSE
                                let decompressedData = try (compressedData as NSData).decompressed(using: .lzfse)
                                
                                // TODO: Combine the two lists, and only add images of entries that does not have a duplicate between the lists
                                dataStore.entries = restoreEntries(from: decompressedData as Data, intersection: dataStore.entries)
                                if let encodedData = try? JSONEncoder().encode(dataStore.entries) {
                                    UserDefaults.standard.set(encodedData, forKey: "entries")
                                }
                                self.presentationMode.wrappedValue.dismiss()
                            } catch {
                                print("Failed to read file: \(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                        print("Import failed: \(error.localizedDescription)")
                    }
            }
            .padding()
            Button(action: {
                showFileImporterReplace = true
            }) {
                Text("File Upload: Replace")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .fileImporter(
                isPresented: $showFileImporterReplace,
                allowedContentTypes: [.data], // Accepts generic data files
                allowsMultipleSelection: false
            ) { result in
                switch result {
                    case .success(let urls):
                        if let fileURL = urls.first {
                            do {
                                // Read the selected file
                                let compressedData = try Data(contentsOf: fileURL)
                                
                                let decompressedData = try (compressedData as NSData).decompressed(using: .lzfse)
                                dataStore.entries = restoreEntries(from: decompressedData as Data, intersection: nil)
                                if let encodedData = try? JSONEncoder().encode(dataStore.entries) {
                                    UserDefaults.standard.set(encodedData, forKey: "entries")
                                }
                                self.presentationMode.wrappedValue.dismiss()
                            } catch {
                                print("Failed to read file: \(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                        print("Import failed: \(error.localizedDescription)")
                    }
            }
            .padding()
        }
    }
}

struct CompressedFile: FileDocument {
    static var readableContentTypes: [UTType] { [.data] } // Use binary data type
    
    var data: Data

    init(data: Data = Data()) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        guard let loadedData = configuration.file.regularFileContents else {
            throw NSError(domain: "FileDocumentError", code: 1, userInfo: nil)
        }
        self.data = loadedData
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

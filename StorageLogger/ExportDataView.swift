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
    @State private var dataJson = CompressedFile()
    @State private var showFileExplorer = false
    @State private var showFileImporter = false
    @ObservedObject var dataStore = DataStore()
    
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
            Text("Backup Data")
                .font(.title)
                .padding()

            Button(action: {
                let data = Data("{\"data\": \"Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World Hello World \"}".utf8)
                do {
                    let compressedData = try (data as NSData).compressed(using: .lzfse)
                    print(compressedData)
                    dataJson = CompressedFile(data: compressedData as Data)
                } catch {
                    print(error.localizedDescription)
                }
                showFileExplorer = true
            }) {
                Text("Download Backup JSON")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .fileExporter(isPresented: $showFileExplorer, document: dataJson, contentType: .json) { result in
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
                showFileImporter = true
            }) {
                Text("Upload Backup JSON")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .fileImporter(
                isPresented: $showFileImporter,
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
                                
                                // Decompress using LZFSE
                                if let jsonString = String(data: decompressedData as Data, encoding: .utf8) {
                                    print("Decompressed JSON: \(jsonString)")
                                    
                                    // Store decompressed data for later use
                                    dataJson = CompressedFile(data: decompressedData as Data)
                                } else {
                                    print("Decompression succeeded, but data is not valid JSON")
                                }
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

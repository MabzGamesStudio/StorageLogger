//
//  ExportDataView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/23/25.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

struct ExportDataView: View {
    @State private var dataJson = JsonFile()
    @State private var showFileExplorer = false
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
                dataJson = JsonFile(data: Data("{\"data\": \"Hello World\"}".utf8))
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
        }
    }
}

struct JsonFile: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
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

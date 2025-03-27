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
    @State private var showShareSheet = false
    @State private var exportedFileURL: URL?
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
                exportedFileURL = exportDataStoreToJSON()
                showShareSheet = exportedFileURL != nil
            }) {
                Text("Download Backup JSON")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $showShareSheet, content: {
            if let url = exportedFileURL {
                ShareSheet(activityItems: [url])
            }
        })
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

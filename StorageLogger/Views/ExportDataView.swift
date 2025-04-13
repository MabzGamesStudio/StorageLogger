//
//  ExportDataView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/23/25.
//

import SwiftUI

/// A view that allows the user to export or import app data using file operations.
///
/// This view provides UI buttons for exporting current data to a file and importing data
/// from a file, either by replacing existing entries or combining them.
struct ExportDataView: View {
    
    /// Environment variable to control dismissing the view.
    @Environment(\.presentationMode) var presentationMode
    
    /// Flag that controls the display of the file exporter UI.
    @State private var showFileExplorer = false
    
    /// Flag to control showing the file importer for combining entries.
    @State private var showFileImporterCombine = false
    
    /// Flag to control showing the file importer for replacing entries.
    @State private var showFileImporterReplace = false
    
    /// View model responsible for handling data export and import logic.
    @ObservedObject var viewModel: ExportDataViewModel

    /// Initializes the view with a given `DataStore` to operate on.
    /// - Parameter dataStore: The shared data source containing entries to be exported or imported.
    init(dataStore: DataStore) {
        viewModel = ExportDataViewModel(dataStore: dataStore)
    }
    
    /// The main UI body of the view.
    var body: some View {
        VStack {
            
            // Export data section with download option
            Text("Export Data")
                .font(.title)
                .padding()

            // Download data to user selected folder
            Button(action: {
                viewModel.exportData()
                showFileExplorer = true
            }) {
                Text("Download")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .fileExporter(
                isPresented: $showFileExplorer,
                document: viewModel.exportedFile,
                contentType: .data
            ) { result in
                viewModel.handleExportResult(result)
                presentationMode.wrappedValue.dismiss()
            }

            // Import data section with upload replace and upload combine options
            Text("Import Data")
                .font(.title)
                .padding()

            // Upload file and combine with existing data
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
                allowedContentTypes: [.data],
                allowsMultipleSelection: false
            ) { result in
                viewModel.handleImport(result, replace: false)
                presentationMode.wrappedValue.dismiss()
            }

            // Upload file and replace existing data
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
                allowedContentTypes: [.data],
                allowsMultipleSelection: false
            ) { result in
                viewModel.handleImport(result, replace: true)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

//
//  ExportDataView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/23/25.
//

import SwiftUI

struct ExportDataView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showFileExplorer = false
    @State private var showFileImporterCombine = false
    @State private var showFileImporterReplace = false
    @ObservedObject var viewModel: ExportDataViewModel

    init(dataStore: DataStore) {
        viewModel = ExportDataViewModel(dataStore: dataStore)
    }
    
    var body: some View {
        VStack {
            Text("Export Data")
                .font(.title)
                .padding()

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
            }

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
                allowedContentTypes: [.data],
                allowsMultipleSelection: false
            ) { result in
                viewModel.handleImport(result, replace: false)
                presentationMode.wrappedValue.dismiss()
            }

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

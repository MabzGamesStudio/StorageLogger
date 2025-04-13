//
//  CompressedFile.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/12/25.
//

import UniformTypeIdentifiers
import SwiftUI

/// A document type that represents a compressed binary file for use with SwiftUI's file importer/exporter.
///
/// `CompressedFile` conforms to the `FileDocument` protocol, allowing you to import and export data files
/// (e.g. JSON or binary blobs) in SwiftUI views using `.fileImporter` and `.fileExporter`.
struct CompressedFile: FileDocument {
    
    /// Specifies that this document supports reading and writing generic binary data (`.data`).
    static var readableContentTypes: [UTType] { [.data] }
    
    /// The raw binary contents of the file.
    var data: Data

    /// Initializes a `CompressedFile` with optional data.
    ///
    /// - Parameter data: The binary data to initialize the document with. Defaults to empty `Data()`.
    init(data: Data = Data()) {
        self.data = data
    }

    /// Initializes a `CompressedFile` from a `ReadConfiguration`, typically used during file import.
    ///
    /// - Parameter configuration: The system-provided configuration that contains the file data.
    /// - Throws: An error if the file contents could not be read.
    init(configuration: ReadConfiguration) throws {
        guard let loadedData = configuration.file.regularFileContents else {
            throw NSError(domain: "FileDocumentError", code: 1, userInfo: nil)
        }
        self.data = loadedData
    }

    /// Encodes the document into a `FileWrapper` for writing to disk.
    ///
    /// - Parameter configuration: The system-provided write configuration.
    /// - Returns: A `FileWrapper` containing the file's binary data.
    /// - Throws: An error if the wrapper cannot be created.
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

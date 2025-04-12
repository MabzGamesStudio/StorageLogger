//
//  CompressedFile.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/12/25.
//

import UniformTypeIdentifiers
import SwiftUI

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

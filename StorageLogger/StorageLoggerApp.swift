//
//  StorageLoggerApp.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/2/25.
//

import SwiftUI
import FirebaseCore

@main
struct StorageLogger: App {
    init() {
//        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            EntriesListView()
        }
    }
}

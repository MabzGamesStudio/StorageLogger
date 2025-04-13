//
//  StorageLoggerApp.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/2/25.
//

import SwiftUI
import GoogleMobileAds

/// The main entry point of the StorageLogger SwiftUI application.
/// Configures Google Mobile Ads and launches the main view of the app.
@main
struct StorageLogger: App {
    
    /// Initializes the app by configuring Google Mobile Ads (AdMob).
    ///
    /// - Sets the test device identifier to ensure ads behave in test mode on the specified device if in debug mode.
    /// - Starts the Mobile Ads SDK.
    init() {
        
        // Show test ads only in development
        #if DEBUG
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "225a96dcd01cf6e60e6bebe2b9c21836" ]
        #endif
        
        // Initialize the Google Mobile Ads SDK
        MobileAds.shared.start { _ in }
    }

    /// The main content scene of the app.
    ///
    /// - Returns a `WindowGroup` containing the app's root view, `EntriesListView`.
    var body: some Scene {
        WindowGroup {
            EntriesListView()
        }
    }
}

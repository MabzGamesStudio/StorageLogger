//
//  StorageLoggerApp.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/2/25.
//

import SwiftUI
import GoogleMobileAds

@main
struct StorageLogger: App {
    init() {
        MobileAds.shared.requestConfiguration.testDeviceIdentifiers = [ "225a96dcd01cf6e60e6bebe2b9c21836" ]
        MobileAds.shared.start { status in
            print("AdMob SDK Initialized:", status.adapterStatusesByClassName)
        }
    }

    var body: some Scene {
        WindowGroup {
            EntriesListView()
        }
    }
}

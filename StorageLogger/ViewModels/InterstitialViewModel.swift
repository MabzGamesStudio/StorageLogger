//
//  InterstitialViewModel.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/30/25.
//

import GoogleMobileAds
import SwiftUI

/// A view model that manages the lifecycle and presentation of an interstitial ad.
/// It handles loading, displaying, and tracking the readiness state of the ad.
///
/// Conforms to `ObservableObject` so views can react to changes,
/// and `FullScreenContentDelegate` to handle full-screen ad callbacks.
class InterstitialViewModel: NSObject, ObservableObject, FullScreenContentDelegate {
    
    /// A published property indicating whether the interstitial ad is ready to be shown.
    /// Views can observe this to enable/disable ad-related UI.
    @Published private(set) var isAdReady = false
    
    /// The currently loaded interstitial ad object.
    private var interstitialAd: InterstitialAd?
    
    /// The unique identifier for the ad unit configured in AdMob.
    private let adUnitID = "ca-app-pub-8507303924736231/2795016851"
    
    /// Initializes the view model and begins loading an interstitial ad asynchronously.
    override init() {
        super.init()
        Task {
            await loadAd()
        }
    }
    
    /// Asynchronously loads a new interstitial ad using the specified ad unit ID.
    /// Sets the delegate and updates the ad readiness state.
    @MainActor
    func loadAd() async {
        do {
            interstitialAd = try await InterstitialAd.load(
                with: adUnitID, request: Request())
            interstitialAd?.fullScreenContentDelegate = self
            self.isAdReady = true
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
            self.isAdReady = false
        }
    }
    
    /// Presents the loaded interstitial ad if it is ready.
    /// If not ready, logs a message and does nothing.
    func showAd() {
        guard isAdReady else {
            print("Ad wasn't ready")
            return
        }
        
        // Present the ad from the topmost view controller (nil defaults to current scene)
        interstitialAd?.present(from: nil)
    }
}

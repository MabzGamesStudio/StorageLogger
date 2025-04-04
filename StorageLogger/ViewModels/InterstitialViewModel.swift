//
//  InterstitialViewModel.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/30/25.
//

import GoogleMobileAds

class InterstitialViewModel: NSObject, ObservableObject, FullScreenContentDelegate {
    @Published private(set) var isAdReady = false
    private var interstitialAd: InterstitialAd?
    private let adUnitID = "ca-app-pub-8507303924736231/2795016851"
    
    override init() {
        super.init()
        Task {
            await loadAd()
        }
    }
    
    func loadAd() async {
        do {
            interstitialAd = try await InterstitialAd.load(
                with: adUnitID, request: Request())
            interstitialAd?.fullScreenContentDelegate = self
            isAdReady = true
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
            isAdReady = false
        }
    }
    
    func showAd() {
        guard isAdReady else {
            print("Ad wasn't ready")
            return
        }

        interstitialAd?.present(from: nil)
    }
}

//
//  InterstitialViewModel.swift
//  StorageLogger
//
//  Created by Matthew Lips on 3/30/25.
//

import GoogleMobileAds

class InterstitialViewModel: NSObject, ObservableObject, FullScreenContentDelegate {
    @Published private var interstitialAd: InterstitialAd?
    
    override init() {
        super.init()
        Task {
            await loadAd()
        }
    }
    
    func loadAd() async {
        do {
            interstitialAd = try await InterstitialAd.load(
                with: "ca-app-pub-8507303924736231/2795016851", request: Request())
            interstitialAd?.fullScreenContentDelegate = self
        } catch {
            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
        }
    }
    
    func showAd() {
        guard let interstitialAd = interstitialAd else {
            return print("Ad wasn't ready.")
        }

        interstitialAd.present(from: nil)
    }
}

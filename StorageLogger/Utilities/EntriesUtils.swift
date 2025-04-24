//
//  EntriesUtils.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/3/25.
//

import Foundation
import AVFoundation
import Photos

/// Decodes an array of `EntryWithBase64` objects from JSON data.
///
/// - Parameter jsonData: The raw JSON data.
/// - Returns: An array of `EntryWithBase64` instances if decoding is successful, otherwise `nil`.
func decodeEntries(from jsonData: Data) -> [EntryWithBase64]? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try? decoder.decode([EntryWithBase64].self, from: jsonData)
}

/// Converts an array of `Entry` objects into a pretty-printed JSON string, with embedded base64 image data and iso8601 date encoding.
///
/// - Parameter entries: An array of `Entry` objects.
/// - Returns: A JSON string representation of the entries (as `EntryWithBase64`) if encoding succeeds, otherwise `nil`.
func convertEntriesToJson(entries: [Entry]) -> String? {
    let entriesWithBase64 = entries.map { entry in
        EntryWithBase64(
            id: entry.id,
            imageBase64: convertImageToBase64(filename: entry.imageFilename),
            name: entry.name,
            price: entry.price,
            quantity: entry.quantity,
            description: entry.description,
            notes: entry.notes,
            tags: entry.tags,
            buyDate: entry.buyDate
        )
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    encoder.dateEncodingStrategy = .iso8601
    return try? String(data: encoder.encode(entriesWithBase64), encoding: .utf8)
}

/// Converts a saved image file (referenced by filename) into a base64-encoded string.
///
/// - Parameter filename: The image filename located in the "ImageData" directory.
/// - Returns: A base64-encoded string of the image data if successful, otherwise `nil`.
private func convertImageToBase64(filename: String?) -> String? {
    guard let filename = filename else { return nil }
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("ImageData")
        .appendingPathComponent(filename)
    return try? Data(contentsOf: fileURL).base64EncodedString()
}

/// Checks the current camera permission status and requests access if not yet determined.
///
/// This function queries the camera authorization status and behaves as follows:
/// - If already authorized, the completion handler is called with `true`.
/// - If not determined, it prompts the user for camera access and returns the result asynchronously.
/// - If access is denied or restricted, the completion handler is called with `false`.
/// - For unknown future cases, it defaults to `false`.
///
/// - Parameter completion: A closure that receives a Boolean indicating whether access was granted.
func checkCameraPermission(completion: @escaping (Bool) -> Void) {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
    }
}

/// Checks the current photo library permission status and requests access if not yet determined.
///
/// This function checks the photo library authorization status and behaves as follows:
/// - If already authorized, the completion handler is called with `true`.
/// - If not determined, it prompts the user for access and returns the result asynchronously.
/// - If access is denied, restricted, or limited, the completion handler is called with `false`.
/// - For unknown future cases, it defaults to `false`.
///
/// - Parameter completion: A closure that receives a Boolean indicating whether access was granted.
func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
    switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized)
                }
            }
        case .denied, .restricted, .limited:
            completion(false)
        @unknown default:
            completion(false)
    }
}

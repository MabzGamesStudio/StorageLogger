//
//  ImagePicker.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/8/25.
//

import SwiftUI

/// A SwiftUI wrapper for `UIImagePickerController` that allows users to pick an image from their photo library or camera.
///
/// Use this struct to integrate UIKit's `UIImagePickerController` into SwiftUI by conforming to `UIViewControllerRepresentable`.
struct ImagePicker: UIViewControllerRepresentable {
    
    /// A binding to the selected image. This will be set when the user picks an image.
    @Binding var image: UIImage?
    
    /// The source type for the image picker (e.g., `.photoLibrary`, `.camera`).
    var sourceType: UIImagePickerController.SourceType

    /// Creates the `UIImagePickerController` instance and configures it.
    ///
    /// - Parameter context: The context provided by SwiftUI for creating the view controller.
    /// - Returns: A configured `UIImagePickerController`.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    /// Updates the `UIImagePickerController` when the SwiftUI view changes.
    ///
    /// Not used in this implementation, but required by the protocol.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    /// Creates a `Coordinator` instance to act as the delegate for the image picker.
    ///
    /// - Returns: An instance of `Coordinator`.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// A delegate class that acts as the bridge between UIKit and SwiftUI.
    ///
    /// Handles image selection and dismissal of the image picker.
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        /// A reference to the parent `ImagePicker` so we can modify the bound image.
        let parent: ImagePicker

        /// Initializes the coordinator with a reference to the parent `ImagePicker`.
        ///
        /// - Parameter parent: The parent `ImagePicker` instance.
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        /// Called when the user selects an image or cancels the picker.
        ///
        /// - Parameters:
        ///   - picker: The `UIImagePickerController` instance.
        ///   - info: A dictionary containing the selected media information.
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

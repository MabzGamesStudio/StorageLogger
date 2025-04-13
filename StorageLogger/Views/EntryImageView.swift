//
//  EntryImageView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/6/25.
//

import SwiftUI

/// A view responsible for displaying an image associated with an entry.
///
/// If a valid image filename is provided and the image is successfully loaded
/// from the documents directory, it shows the image. Otherwise, it shows a placeholder icon.
struct EntryImageView: View {
    
    /// The optional filename of the image to load from the app's documents directory.
    let imageFilename: String?
    
    /// The view body that determines which image to show based on the presence of a valid filename and image.
    var body: some View {
        Group {
            
            // If a valid imageFilename is available and the image can be loaded,
            // show the image with a styled frame and rounded corners.
            if let imageFilename, let image = loadImageFromDocumentsDirectory(filename: imageFilename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                
                // If image loading fails or filename is nil, show a default placeholder icon.
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }
        }
        
        // Add right padding to separate this view from surrounding content.
        .padding(.trailing, 10)
    }
}

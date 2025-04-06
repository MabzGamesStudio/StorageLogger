//
//  EntryImageView.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/6/25.
//

import SwiftUI

struct EntryImageView: View {
    let imageFilename: String?
    
    var body: some View {
        Group {
            if let imageFilename, let image = loadImageFromDocumentsDirectory(filename: imageFilename) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }
        }
        .padding(.trailing, 10)
    }
}

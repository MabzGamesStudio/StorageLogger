//
//  Formatting.swift
//  StorageLogger
//
//  Created by Matthew Lips on 4/6/25.
//

import SwiftUI

/// Formats a `Date` object into a human-readable string in "MM/dd/yyyy" format.
///
/// - Parameter date: The `Date` to be formatted.
/// - Returns: A `String` representing the formatted date.
func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter.string(from: date)
}

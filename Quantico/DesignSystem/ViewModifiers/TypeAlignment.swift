//
//  File.swift
//
//
//  Created by 李天培 on 2022/7/5.
//

import Foundation

#if os(macOS)
import AppKit

public typealias PlatformImage = NSImage

public extension NSImage {
    convenience init?(systemName: String) {
        self.init(systemSymbolName: systemName, accessibilityDescription: systemName)
    }
}
#else
import UIKit

public typealias PlatformImage = UIImage
#endif

#if os(macOS)
public typealias PlatformFont = NSFont
#else
public typealias PlatformFont = UIFont
#endif

import SwiftUI

public extension Image {
    init(platformImage: PlatformImage) {
#if os(macOS)
        self.init(nsImage: platformImage)
#else
        self.init(uiImage: platformImage)
#endif
    }
}


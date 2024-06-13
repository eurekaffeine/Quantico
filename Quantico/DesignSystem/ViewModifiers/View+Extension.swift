//
//  View+Extension.swift
//
//
//  Created by tianpli on 2024/1/22.
//

import SwiftUI

extension View {
    /// same value for width and height.
    @ViewBuilder
    public func frame(size: CGFloat) -> some View {
        frame(width: size, height: size)
    }
}

public extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = true) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }

}

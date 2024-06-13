//
//  SAOverlayView.swift
//
//
//  Created by tianpli on 2024/2/18.
//

import SwiftUI

public struct SAOverlayView: View {
    public init() {
    }
    
    @Environment(\.saTheme)
    private var theme: SATheme
    
    public var body: some View {
        Color.black
            .opacity(opacity)
            .ignoresSafeArea()
            .transition(.opacity.animation(.easeIn))
    }
    
    private var opacity: CGFloat {
        switch theme {
        case .light:
            return 0.4
        case .dark:
            return 0.6
        }
    }
}

//
//  StrokeView.swift
//
//
//  Created by tianpli on 2024/1/22.
//

import SwiftUI

// MARK: - StrokeView
public struct StrokeView: View {
    public init(color: SAColor = .dividerPrimary, width: SALayout.StrokeWidth = .strokeWidth05) {
        self.color = color
        self.width = width
    }
    
    var color: SAColor = .dividerPrimary
    var width: SALayout.StrokeWidth = .strokeWidth05
    
    public var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity, maxHeight: width.value)
            .foregroundColor(for: color)
    }
}

//#Preview {
//    StrokeView()
//}

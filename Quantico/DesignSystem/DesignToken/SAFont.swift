//
//  File.swift
//  
//
//  Created by 李天培 on 2023/10/20.
//

import Foundation
import SwiftUI

public enum SAFont: CaseIterable {
    case caption2
    case caption1
    case subhead
    case body2
    case body2Strong
    case callout
    case body1
    case headline
    case body1Strong
    case title3
    case title2
    case title1
    case largeTitle
    case caption1Strong
}

extension SAFont {
    var descrption: String {
        switch self {
        case .caption2:
            return "Small subtext"
        case .title2:
            return "Title 2 (OS), Dialog"
        case .caption1:
            return "Subtext, Tab bar label, labels"
        case .caption1Strong:
            return "Large Subtext, Small button"
        case .body1:
            return "Feeds body text, system body text (profile, settings), onboarding FRE body text"
        case .body2:
            return "Navigation labels, notification body text, input box, feeds subtext"
        case .headline:
            return "Notification title, Large button labels, system section title, highlighted text"
        case .callout:
            return "Snack bar title, medium button label, glance card FRE, profile section title, highlighted text"
        case .subhead:
            return "Glance card title, homepage banner, small button label"
        case .body1Strong:
            return "Explore AI caption"
        case .title3:
            return "Header title, loading message title, error message title"
        case .title1:
            return "eEmphasized text (temperature, rewards points)"
        case .largeTitle:
            return "Large emphasized text (Commute distance), onboarding FRE title"
        case .body2Strong:
            return "upsell text"
        }
    }
    
    var lineSpacing: CGFloat {
        return 2
    }
    // Warning: It is useless cause Apple do not support Font by family name directly.
    var family: String {
        switch self {
        case .caption2, .caption1, .subhead, .body1, .body2, .headline, .callout, .body1Strong, .caption1Strong, .body2Strong:
            return "SF Pro Text"
        case .title2, .title1, .title3, .largeTitle:
            return "SF Pro Display"
        }
    }
    
    var weight: Font.Weight {
        switch self {
        case .caption2, .caption1, .body1, .body2:
            return .regular
        case .callout, .subhead:
            return .medium
        case .title2, .headline, .title3, .caption1Strong, .body2Strong:
            return .semibold
        case .title1, .body1Strong, .largeTitle:
            return .bold
        }
    }
    
    var size: CGFloat {
        switch self {
        case .caption1, .caption1Strong:
            return 12
        case .subhead:
            return 13
        case .callout, .body2Strong, .body2:
            return 15
        case .caption2, .body1, .headline:
            return 16
        case .body1Strong:
            return 17
        case .title3:
            return 20
        case .title2:
            return 22
        case .title1:
            return 26
        case .largeTitle:
            return 34
        }
    }
    
    public var font: Font {
        Font.system(size: size, weight: weight)
    }
}

#if canImport(UIKit)
public extension SAFont {
    var uiWeight: UIFont.Weight {
        switch self {
        case .caption2, .caption1, .body1, .body2:
            return .regular
        case .callout, .subhead:
            return .medium
        case .title2, .headline, .title3, .caption1Strong, .body2Strong:
            return .semibold
        case .title1, .body1Strong, .largeTitle:
            return .bold
        }
    }
    
    var uiFont: UIFont {
        UIFont.systemFont(ofSize: size, weight: uiWeight)
    }
}
#endif

public extension View {
    func font(for saFont: SAFont) -> some View {
        font(saFont.font)
            .lineSpacing(saFont.lineSpacing)
            .padding(.vertical, saFont.lineSpacing)
    }
}

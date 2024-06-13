//
//  SAButton.swift
//
//
//  Created by tianpli on 2024/1/12.
//

import SwiftUI
//#if canImport(UIKit)

public struct SAButtonConfiguration {
    public init(title: String?, icon: PlatformImage? = nil, style: AlertActionStyle = .default, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    public var title: String?
    public var icon: PlatformImage?
    public var style: AlertActionStyle = .default
    public var action: () -> Void
}

enum SAButtonStyle {
    case primary
    case secondary
    case tertiary
}

enum SAButtonSize {
    case small
    case medium
    case large
}

struct SAButton: View {
    enum State {
        case normal
        case disabled
        case warning
    }
    
    enum Kind {
        case `default`
        case icon
    }
    
    var style: SAButtonStyle = .primary
    var size: SAButtonSize = .medium
    var state: State = .normal
    var kind: Kind = .default
    
    var isLeadingIcon: Bool = false
    var isTrailingIcon: Bool = false
    /// Both for label and accessibility
    var label: String
    var icon: PlatformImage? = nil
    var action: () -> Void
    
    @Environment(\.saTheme)
    private var theme: SATheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: spacing) {
                if let icon, isLeadingIcon {
                    iconView(icon: icon)
                }
                if kind == .default && !label.isEmpty {
                    Text(label)
                        .font(for: .headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(for: textColor)
                }
                if let icon, isTrailingIcon {
                    iconView(icon: icon)
                }
            }
            .padding(.horizontal, padding)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .backgroundColor(for: backgroundColor)
            .radius(for: kind == .default && !label.isEmpty ? .cornerRadius240 : .cornerRadiusCircular, stroke: stroke)
        }
        .disabled(state == .disabled)
        .accessibilityLabel(label)
    }
    
    private func iconView(icon: PlatformImage) -> some View {
        Image(platformImage: icon)
            .resizable()
            .renderingMode(.template)
            .foregroundColor(for: textColor)
            .frame(size: iconSize) // TODO: Size 16 small
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .small:
            return .icon160
        default:
            return .icon200
        }
    }
    
    private var height: CGFloat {
        switch size {
        case .small:
            return 28
        case .medium:
            return 36
        case .large:
            return 48
        }
    }
    
    private var padding: CGFloat {
        switch size {
        case .small:
            return .spacing120
        case .medium:
            return .spacing160
        case .large:
            return .spacing240
        }
    }
    
    private var font: SAFont {
        switch size {
        case .small:
            return .caption1Strong
        case .medium:
            return .callout
        case .large:
            return .headline
        }
    }
    
    private var spacing: CGFloat {
        switch size {
        case .small:
            return .spacing40
        case .medium, .large:
            return .spacing80
        }
    }
    
    private var stroke: (Color, SALayout.StrokeWidth)? {
        switch (style, state) {
        case (.secondary, .warning):
            return (SAColor.textDanger.color(for: theme), .strokeWidth10)
        default:
            return nil
        }
    }
    
    private var backgroundColor: SAColor {
        switch (style, state) {
        case (.primary, .normal):
            return .surfaceBrandPrimary
        case (.primary, .disabled):
            return .surfaceTertiary
        case (.primary, .warning):
            return .textDanger
        case (.secondary, .normal):
            return .surfaceTertiary
        case (.secondary, .disabled):
            return .surfaceTertiary
        case (.secondary, .warning):
            return .clear
        case (.tertiary, _):
            return .clear
        }
    }
    
    private var textColor: SAColor {
        switch (style, state) {
        case (_, .disabled):
            return .textDisabled
        case (.primary, _):
            return .textOnBrand
        case (.secondary, .normal):
            return .textPrimary
        case (.secondary, .warning), (.tertiary, .warning):
            return .textDanger
        case (.tertiary, .normal):
            return .textBrandPrimary
        }
    }
}

//#Preview {
//    SAButton(style: .primary, size: .large, state: .warning, kind: .default, isLeadingIcon: true, isTrailingIcon: false, label: "", icon: PlatformImage(systemName: "hand.thumbsup")) {
//        
//    }
//    .fixedSize(horizontal: true, vertical: true)
//    .padding()
////    .environment(\.saTheme, .dark)
////    .background(Color.black)
//}

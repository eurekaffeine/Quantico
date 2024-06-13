//
//  Theme.swift
//
//
//  Created by tianpli on 2023/9/25.
//

import Foundation
import SwiftUI

public enum SATheme: CaseIterable {
    case light
    case dark
}

public extension SAColor {
    internal func globalColor(for theme: SATheme) -> GlobalColor {
        guard let color = Self.colorMap[self]?[theme] else {
            fatalError("Alias token color should have a global token color for a theme")
        }
        return color
    }
    func color(for theme: SATheme) -> Color {
        globalColor(for: theme).color
    }
}

#if canImport(UIKit)
import UIKit

public extension SAColor {
    func uiColor(for theme: SATheme) -> UIColor {
        globalColor(for: theme).uiColor
    }
}

public extension UIColor {
    static func saColor(_ color: SAColor, theme: SATheme) -> UIColor {
        color.uiColor(for: theme)
    }
    
    convenience init(saColor: SAColor, theme: SATheme) {
            self.init(saColor.color(for: theme))
    }
    
    @available(iOS 17.0, *)
    convenience init(saColor: SAColor) {
        self.init { collection in
            saColor.uiColor(for: collection.theme)
        }
    }
}

@available(iOS 17.0, *)
extension UITraitCollection {
    var theme: SATheme { self[SAThemeTrait.self] }
}

@available(iOS 17.0, *)
public extension UIMutableTraits {
    var theme: SATheme {
        get { self[SAThemeTrait.self] }
        set { self[SAThemeTrait.self] = newValue }
    }
}

struct SAThemeTrait: UITraitDefinition {
    static let defaultValue = SATheme.light
}

#endif

private struct SAThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue: SATheme = .light
}

public extension EnvironmentValues {
    var saTheme: SATheme {
        get { self[SAThemeEnvironmentKey.self] }
        set { self[SAThemeEnvironmentKey.self] = newValue }
    }
}

public extension View {
    func saTheme(_ saTheme: SATheme) -> some View {
        environment(\.saTheme, saTheme)
    }
    
    func backgroundColor(for saColor: SAColor) -> some View {
        modifier(SAColorEnvironmentalModifier(color: saColor, modifier: .background))
    }
    
    func foregroundColor(for saColor: SAColor) -> some View {
        modifier(SAColorEnvironmentalModifier(color: saColor, modifier: .foreground))
    }
}

enum SAColorModifier {
    case background
    case foreground
}

struct SAColorViewModifier: ViewModifier {
    var theme: SATheme
    var color: SAColor
    var modifier: SAColorModifier
    func body(content: Content) -> some View {
        switch modifier {
        case .background:
            content
                .background(color.globalColor(for: theme).color)
        case .foreground:
            content
                .foregroundStyle(color.globalColor(for: theme).color)
        }
    }
}

struct SAColorEnvironmentalModifier: EnvironmentalModifier, Sendable {
    var color: SAColor
    var modifier: SAColorModifier
    func resolve(in environment: EnvironmentValues) -> some ViewModifier {
        SAColorViewModifier(theme: environment.saTheme, color: color, modifier: modifier)
    }
}

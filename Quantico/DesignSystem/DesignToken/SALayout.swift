//
//  File.swift
//  
//
//  Created by 李天培 on 2023/10/20.
//

import Foundation
import SwiftUI

public struct SALayout {
    public enum IconSize {
        case iconSize100
        case iconSize120
        case iconSize160
        case iconSize200
        case iconSize240
        case iconSize280
        case iconSize320
        case iconSize360
        case iconSize400
        case iconSize480
    }
    
    public enum StrokeWidth {
        case strokeWidthNone
        case strokeWidth05
        case strokeWidth10
        case strokeWidth15
    }
    
    public enum Shadow {
        case shadow02
        case shadow04
    }
    
    public enum CornerRadius {
        case cornerRadiusNone
        case cornerRadius20
        case cornerRadius80
        case cornerRadius120
        case cornerRadius160
        case cornerRadius240
        case cornerRadiusInfinity
        case cornerRadiusCircular
    }
    
    public enum SpacingSize {
        case sizeNone
        case size20
        case size40
        case size60
        case size80
        case size100
        case size120
        case size160
        case size200
        case size240
        case size280
        case size320
        case size360
        case size400
        case size440
        case size480
        case size520
        case size560
    }
}
// MARK: - Icon Size
extension SALayout.IconSize {
    var value: CGFloat {
        switch self {
        case .iconSize100:
            return 10
        case .iconSize120:
            return 12
        case .iconSize160:
            return 16
        case .iconSize200:
            return 20
        case .iconSize240:
            return 24
        case .iconSize280:
            return 28
        case .iconSize320:
            return 32
        case .iconSize360:
            return 36
        case .iconSize400:
            return 40
        case .iconSize480:
            return 48
        }
    }
}

public extension CGFloat {
    static var icon100: CGFloat { SALayout.IconSize.iconSize100.value }
    static var icon120: CGFloat { SALayout.IconSize.iconSize120.value }
    static var icon160: CGFloat { SALayout.IconSize.iconSize160.value }
    static var icon200: CGFloat { SALayout.IconSize.iconSize200.value }
    static var icon240: CGFloat { SALayout.IconSize.iconSize240.value }
    static var icon280: CGFloat { SALayout.IconSize.iconSize280.value }
    static var icon320: CGFloat { SALayout.IconSize.iconSize320.value }
    static var icon360: CGFloat { SALayout.IconSize.iconSize360.value }
    static var icon400: CGFloat { SALayout.IconSize.iconSize400.value }
    static var icon480: CGFloat { SALayout.IconSize.iconSize480.value }
}

// MARK: - Stroke Width
public extension SALayout.StrokeWidth {
    var value: CGFloat {
        switch self {
        case .strokeWidthNone:
            return 0
        case .strokeWidth05:
            return 0.5
        case .strokeWidth10:
            return 1
        case .strokeWidth15:
            return 1.5
        }
    }
    var description: String {
        switch self {
        case .strokeWidthNone:
            return "No stroke or placeholder stroke"
        case .strokeWidth05:
            return "Separators"
        case .strokeWidth10:
            return "Button outline, radio, cardnudge."
        case .strokeWidth15:
            return "Fluent Icons and Activity Rings (inner rings and small inactive)"
        }
    }
}

extension CGFloat {
    public static var strokeWidthNone: CGFloat { SALayout.StrokeWidth.strokeWidthNone.value }
    public static var strokeWidth05: CGFloat { SALayout.StrokeWidth.strokeWidth05.value }
    public static var strokeWidth10: CGFloat { SALayout.StrokeWidth.strokeWidth10.value }
}
// MARK: - Shadow
struct ShadowModel {
    // base shadow
    let baseX: CGFloat
    let baseColor: CGColor
    let baseY: CGFloat
    let baseBlur: CGFloat
    // offset shadow
    let offsetX: CGFloat
    let offsetColor: CGColor
    let offsetY: CGFloat
    let offsetBlur: CGFloat
}

extension SALayout.Shadow {
    func shadow(for theme: SATheme) -> ShadowModel {
        let x: CGFloat = 0
        // base shadow
        let baseColor = CGColor(gray: 1, alpha: theme == .dark ? 0.08 : 0.04)
        let baseY: CGFloat = 0
        let baseBlur: CGFloat = self.baseBlur
        // offset shadow
        let offsetColor = CGColor(gray: 1, alpha: theme == .dark ? 0.24 : 0.12)
        let offsetY: CGFloat = self.offsetY
        let offsetBlur: CGFloat = self.offsetBlur
        return ShadowModel(baseX: x, baseColor: baseColor, baseY: baseY, baseBlur: baseBlur,
                    offsetX: x, offsetColor: offsetColor, offsetY: offsetY, offsetBlur: offsetBlur)
    }
    var baseBlur: CGFloat {
        switch self {
        case .shadow02, .shadow04:
            return 2
        }
    }
    var offsetY: CGFloat {
        switch self {
        case .shadow02, .shadow04:
            return 2
        }
    }
    var offsetBlur: CGFloat {
        switch self {
        case .shadow02:
            return 2
        case .shadow04:
            return 4
        }
    }
}

extension CALayer {
    public func addShadow(for shadow: SALayout.Shadow, theme: SATheme) {
        let baseShadowLayer = CALayer()
        let model = shadow.shadow(for: theme)
        baseShadowLayer.shadowColor = model.baseColor
        baseShadowLayer.shadowRadius = model.baseBlur
        baseShadowLayer.shadowOffset = CGSize(width: model.baseX, height: model.baseY)
        addSublayer(baseShadowLayer)

        let offsetShadowLayer = CALayer()
        offsetShadowLayer.shadowColor = model.offsetColor
        offsetShadowLayer.shadowRadius = model.offsetBlur
        offsetShadowLayer.shadowOffset = CGSize(width: model.offsetX, height: model.offsetY)
        addSublayer(offsetShadowLayer)
    }
}

extension View {
    @ViewBuilder
    public func shadow(for shadow: SALayout.Shadow, theme: SATheme) -> some View {
        let model = shadow.shadow(for: theme)
        self.shadow(color: Color(model.baseColor), radius: model.baseBlur, x: model.baseX, y: model.baseY)
            .shadow(color: Color(model.baseColor), radius: model.baseBlur, x: model.baseX, y: model.baseY)
    }
}

// MARK: - Corner Radius
public extension SALayout.CornerRadius {
    var value: CGFloat {
        switch self {
        case .cornerRadiusNone:
            return 0
        case .cornerRadius20:
            return 2
        case .cornerRadiusInfinity, .cornerRadiusCircular:
            return .infinity
        case .cornerRadius80:
            return 8
        case .cornerRadius160:
            return 16
        case .cornerRadius240:
            return 24
        case .cornerRadius120:
            return 12
        }
    }
    var description: String {
        switch self {
        case .cornerRadiusNone:
            return "Navigation bars, tab bars."
        case .cornerRadiusCircular, .cornerRadiusInfinity:
            return "Personas"
        case .cornerRadius20:
            return "Small cards, badges, popovers"
        case .cornerRadius80:
            return "Small cards, badges, popovers"
        case .cornerRadius160:
            return "Feed cards, Rich Tiles, Cards, Banner, System panel"
        case .cornerRadius240:
            return "Dialog, Panel"
        case .cornerRadius120:
            return "Feed cards, Medium cards, Banner"
        }
    }
}

public extension CGFloat {
    static var cornerRadiusNone: CGFloat { SALayout.CornerRadius.cornerRadiusNone.value }
    static var cornerRadius20: CGFloat { SALayout.CornerRadius.cornerRadius20.value }
    static var cornerRadius80: CGFloat { SALayout.CornerRadius.cornerRadius80.value }
    static var cornerRadius120: CGFloat { SALayout.CornerRadius.cornerRadius120.value }
    static var cornerRadius240: CGFloat { SALayout.CornerRadius.cornerRadius240.value }
    static var cornerRadiusCircular: CGFloat { SALayout.CornerRadius.cornerRadiusCircular.value }
}

public extension View {
    
    @ViewBuilder
    func radius(for cornerRadius: SALayout.CornerRadius, corners: RectCorner = .all, stroke: (color: Color, width: SALayout.StrokeWidth)? = nil) -> some View {
        let stroke = stroke ?? (.clear, .strokeWidthNone)
        switch cornerRadius {
        case .cornerRadiusNone:
            clipShape(Rectangle())
                .overlay(Rectangle().inset(by: stroke.width.value / 2).stroke(stroke.color, lineWidth: stroke.width.value))
        case .cornerRadiusCircular:
            clipShape(Circle())
                .overlay(Circle().inset(by: stroke.width.value / 2).stroke(stroke.color, lineWidth: stroke.width.value))
        default:
            clipShape(RoundedCorner(radius: cornerRadius.value, corners: corners))
                .overlay(RoundedCorner(radius: cornerRadius.value, corners: corners).inset(by: stroke.width.value / 2).stroke(stroke.color, lineWidth: stroke.width.value))
        }
    }
}
public struct RectCorner: OptionSet, Sendable {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public let rawValue: Int
    
    
    public static let topLeading = RectCorner(rawValue: 1 << 0)
    public static let topTrailing = RectCorner(rawValue: 1 << 1)
    public static let bottomLeading = RectCorner(rawValue: 1 << 2)
    public static let bottomTrailing = RectCorner(rawValue: 1 << 3)
    
    
    public static let top: RectCorner = [.topLeading, .topTrailing]
    public static let bottom: RectCorner = [.bottomLeading, .bottomTrailing]
    public static let all: RectCorner = [.topLeading, .topTrailing, .bottomTrailing, .bottomLeading]
}

struct RoundedCorner: Shape, InsettableShape {
    internal init(radius: CGFloat = .infinity, corners: RectCorner = .all) {
        self.radius = radius
        self.corners = corners
    }
    
    var radius: CGFloat = .infinity
    var corners: RectCorner = .all
    private var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        Path { path in
            
            let w = rect.size.width
            let h = rect.size.height
            
            // Make sure we do not exceed the size of the rectangle
            let tl = min(min(radius(for: .topLeading), h/2), w/2)
            let tt = min(min(radius(for: .topTrailing), h/2), w/2)
            let bl = min(min(radius(for: .bottomLeading), h/2), w/2)
            let bt = min(min(radius(for: .bottomTrailing), h/2), w/2)
            
            path.move(to: CGPoint(x: w / 2.0, y: insetAmount))
            path.addLine(to: CGPoint(x: w - tt - insetAmount, y: insetAmount))
            path.addArc(center: CGPoint(x: w - tt - insetAmount, y: tt + insetAmount),
                        radius: tt,
                        startAngle: Angle(degrees: -90),
                        endAngle: Angle(degrees: 0),
                        clockwise: false)
            path.addLine(to: CGPoint(x: w - insetAmount, y: h - bt - insetAmount))
            path.addArc(center: CGPoint(x: w - bt - insetAmount, y: h - bt - insetAmount),
                        radius: bt,
                        startAngle: Angle(degrees: 0),
                        endAngle: Angle(degrees: 90),
                        clockwise: false)
            path.addLine(to: CGPoint(x: bl + insetAmount, y: h - insetAmount))
            path.addArc(center: CGPoint(x: bl + insetAmount, y: h - bl - insetAmount),
                        radius: bl,
                        startAngle: Angle(degrees: 90),
                        endAngle: Angle(degrees: 180),
                        clockwise: false)
            path.addLine(to: CGPoint(x: insetAmount, y: tl + insetAmount))
            path.addArc(center: CGPoint(x: tl + insetAmount, y: tl + insetAmount),
                        radius: tl,
                        startAngle: Angle(degrees: 180),
                        endAngle: Angle(degrees: 270),
                        clockwise: false)
            path.closeSubpath()
        }
    }
    
    func inset(by amount: CGFloat) -> RoundedCorner {
        var shape = self
        shape.insetAmount += amount
        return shape
    }
    
    private func radius(for corner: RectCorner) -> CGFloat {
        corners.contains(corner) ? max(radius - insetAmount, 0) : 0
    }
}

// MARK: - Spacing Size
extension SALayout.SpacingSize {
    var value: CGFloat {
        switch self {
        case .sizeNone:
            return 0
        case .size20:
            return 2
        case .size40:
            return 4
        case .size60:
            return 6
        case .size80:
            return 8
        case .size100:
            return 10
        case .size120:
            return 12
        case .size160:
            return 16
        case .size200:
            return 20
        case .size240:
            return 24
        case .size280:
            return 28
        case .size320:
            return 32
        case .size360:
            return 36
        case .size400:
            return 40
        case .size440:
            return 44
        case .size480:
            return 48
        case .size520:
            return 52
        case .size560:
            return 56
        }
    }
}

extension CGFloat {
    public static var spacingNone: CGFloat { SALayout.SpacingSize.sizeNone.value }
    public static var spacing20: CGFloat { SALayout.SpacingSize.size20.value }
    public static var spacing40: CGFloat { SALayout.SpacingSize.size40.value }
    public static var spacing60: CGFloat { SALayout.SpacingSize.size60.value }
    public static var spacing80: CGFloat { SALayout.SpacingSize.size80.value }
    public static var spacing100: CGFloat { SALayout.SpacingSize.size100.value }
    public static var spacing120: CGFloat { SALayout.SpacingSize.size120.value }
    public static var spacing160: CGFloat { SALayout.SpacingSize.size160.value }
    public static var spacing200: CGFloat { SALayout.SpacingSize.size200.value }
    public static var spacing240: CGFloat { SALayout.SpacingSize.size240.value }
    public static var spacing280: CGFloat { SALayout.SpacingSize.size280.value }
    public static var spacing320: CGFloat { SALayout.SpacingSize.size320.value }
    public static var spacing360: CGFloat { SALayout.SpacingSize.size360.value }
    public static var spacing400: CGFloat { SALayout.SpacingSize.size400.value }
    public static var spacing440: CGFloat { SALayout.SpacingSize.size440.value }
    public static var spacing480: CGFloat { SALayout.SpacingSize.size480.value }
    public static var spacing520: CGFloat { SALayout.SpacingSize.size520.value }
    public static var spacing560: CGFloat { SALayout.SpacingSize.size560.value }
}

struct CenterPopRectangle: Shape {
    var height: CGFloat
    var topContolLegngth: CGFloat
    var downContolLegngth: CGFloat
    var width: CGFloat
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: rect.origin)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

            let center = CGPoint(x: rect.midX, y: rect.minY)
            path.addLine(to: CGPoint(x: center.x + width / 2, y: center.y))
            path.addCurve(to: CGPoint(x: center.x, y: center.y - height),
                          control1: CGPoint(x: center.x + width / 2 - downContolLegngth, y: center.y),
                          control2: CGPoint(x: center.x + topContolLegngth, y: center.y - height))
            path.addCurve(to: CGPoint(x: center.x - width / 2, y: center.y),
                          control1: CGPoint(x: center.x - topContolLegngth, y: center.y - height),
                          control2: CGPoint(x: center.x + downContolLegngth - width / 2, y: center.y))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.closeSubpath()
        }
    }
}

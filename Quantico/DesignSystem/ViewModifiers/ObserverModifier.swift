//
//  ObserverModifier.swift
//
//
//  Created by 李天培 on 2022/8/1.
//

import Combine
import SwiftUI

public struct ChangeObserver<V: Equatable>: ViewModifier {
    public init(newValue: V, action: @escaping (V) -> Void) {
        self.newValue = newValue
        self.newAction = action
    }

    private typealias Action = (V) -> Void

    private let newValue: V
    private let newAction: Action

    @State private var state: (V, Action)?

    public func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            assertionFailure(
                "Please don't use this ViewModifer directly and use the `onChange(of:perform:)` modifier instead."
            )
        }
        return
            content
            .onAppear()
            .onReceive(Just(newValue)) { newValue in
                if let (currentValue, action) = state, newValue != currentValue {
                    action(newValue)
                }
                state = (newValue, newAction)
            }
    }
}

public struct OverlayModifier<OverlayView>: ViewModifier where OverlayView: View {
    public init(alignment: Alignment, overlay: @escaping () -> OverlayView) {
        self.alignment = alignment
        self.overlay = overlay
    }

    private let alignment: Alignment
    private let overlay: () -> OverlayView

    public func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            assertionFailure(
                "Please don't use this ViewModifer directly and use the `onChange(of:perform:)` modifier instead."
            )
        }
        let view = overlay()
        return
            content
            .overlay(view, alignment: alignment)
    }
}

public struct CardModifier<CardView>: ViewModifier where CardView: View {
    public init(corner: CardModifier<CardView>.Corner = Corner(),
                border: CardModifier<CardView>.Border = Border(),
                shadow: CardModifier<CardView>.Shadow = Shadow()) {
        self.corner = corner
        self.border = border
        self.shadow = shadow
    }
    
    public struct Corner {
        public init(radius: CGFloat = 0) {
            self.radius = radius
        }
        
        public var radius: CGFloat = 0
    }
    
    public struct Border {
        public init(width: CGFloat = 0, color: Color = .black) {
            self.width = width
            self.color = color
        }
        
        public var width: CGFloat = 0
        public var color: Color = .black
    }
    
    public struct Shadow {
        public init(color: Color = .black, radius: CGFloat = 0, x: CGFloat = 0, y: CGFloat = 0) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
        
        public var color: Color = .black
        public var radius: CGFloat = 0
        public var x: CGFloat = 0
        public var y: CGFloat = 0
    }
    
    private let corner: Corner
    private let border: Border
    private let shadow: Shadow

    public func body(content: Content) -> some View {
        var content = content
        if corner.radius > 0 {
            content = content.cornerRadius(corner.radius) as! CardModifier<CardView>.Content
        }
        
        if border.width > 0 {
            content = content.padding(border.width)
                .background(border.color)
                .cornerRadius(border.width + corner.radius) as! CardModifier<CardView>.Content
        }
        
        return content
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {
    @ViewBuilder public func card<V>(corner: CardModifier<V>.Corner = CardModifier<V>.Corner(),
                                     border: CardModifier<V>.Border = CardModifier<V>.Border(),
                                     shadow: CardModifier<V>.Shadow = CardModifier<V>.Shadow()) -> some View where V: View {
        modifier(CardModifier<V>(corner: corner, border: border, shadow: shadow))
    }
    
    @_disfavoredOverload
    @ViewBuilder public func overlayView<V>(
        alignment: Alignment = .center, content: @escaping () -> V
    ) -> some View where V: View {
        if #available(iOS 15, *) {
            overlay(alignment: alignment, content: content)
        } else {
            modifier(OverlayModifier(alignment: alignment, overlay: content))
        }
    }

    @_disfavoredOverload
    @ViewBuilder public func onChange<V>(of value: V, perform action: @escaping (V) -> Void)
        -> some View where V: Equatable
    {
        if #available(iOS 14, *) {
            onChange(of: value, perform: action)
        } else {
            modifier(ChangeObserver(newValue: value, action: action))
        }
    }
}
///
public struct SpiralGeometryEffect: GeometryEffect {
    public init(radius: CGFloat, radians: CGFloat, progress: CGFloat) {
        self.radius = radius
        self.radians = radians
        self.progress = progress
        self.animatableData = progress
    }
    public var radius: CGFloat
    public var radians: CGFloat
    public var progress: CGFloat
    
    public var animatableData: CGFloat
    
    public func effectValue(size: CGSize) -> ProjectionTransform {
        let x = animatableData * radians * sin(2 * .pi * (radians + animatableData))
        let y = animatableData * radians * -cos(2 * .pi * (radians + animatableData))
        let translation = CGAffineTransform(translationX: x, y: y)

        return ProjectionTransform(translation)
    }
}

// MARK: - Animation

public struct AnimationProgressObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    public var animatableData: Value {
        didSet {
            notifyProgress()
        }
    }

    /// The completion callback which is called once the animation completes.
    private var completion: (Value) -> Void

    public init(observedValue: Value, completion: @escaping (Value) -> Void) {
        self.completion = completion
        self.animatableData = observedValue
    }

    private func notifyProgress() {

        DispatchQueue.main.async {
            self.completion(animatableData)
        }
    }

    public func body(content: Content) -> some View {
        /// We're not really modifying the view so we can directly return the original input value.
        return content
    }
}

extension View {

    /// Calls the completion handler whenever an animation on the given value completes.
    /// - Parameters:
    ///   - value: The value to observe for animations.
    ///   - completion: The completion callback to call once the animation completes.
    /// - Returns: A modified `View` instance with the observer attached.
    public func onAnimating<Value: VectorArithmetic>(for value: Value, completion: @escaping (Value) -> Void) -> ModifiedContent<Self, AnimationProgressObserverModifier<Value>> {
        return modifier(AnimationProgressObserverModifier(observedValue: value, completion: completion))
    }
}

public struct CenterShakeAnimation: GeometryEffect {
    public var times: Int
    public var degrees: Int
    public init(repeat times: Int, degree: Int = 90) {
        self.times = times
        self.degrees = degree
        animatableData = Double(times)
    }
    
    public func effectValue(size: CGSize) -> ProjectionTransform {
        let x: CGFloat = size.width / 2
        let y: CGFloat = size.height / 2
        let transform = CGAffineTransform(translationX: x, y: y)
            .rotated(by: sin(animatableData * .pi * 2) * Double(degrees) / 180)
            .translatedBy(x: -x, y: -y)
        return ProjectionTransform(transform)
    }
    
    public var animatableData: Double
}

public struct RotationAnimation: GeometryEffect {
    public var degrees: Double
    public var animatableData: Double
    public init(degrees: Double) {
        self.degrees = degrees
        animatableData = degrees
    }
    
    private var bezier = CubicBezier(start: CGPoint(x: 0, y: 0), c1: CGPoint(x: 0.5, y: 0), c2: CGPoint(x: 0.5, y: 1), end: CGPoint(x: 1, y: 1))
    
    public func effectValue(size: CGSize) -> ProjectionTransform {
        let x = size.width / 2
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, x, 0, 0)
        
        let times = animatableData / 180
        transform = CATransform3DRotate(transform, (bezier.calculate(for: times.truncatingRemainder(dividingBy: 1)) + times.rounded(.towardZero)) * .pi, 0, 1, 0)
        return ProjectionTransform(CATransform3DTranslate(transform, -x, 0, 0))
    }
}

public struct JumpAnimation: GeometryEffect {
    public var times: Double
    public var height: Double
    
    public var animatableData: Double
    
    public init(repeat times: Double, height: Double) {
        self.times = times
        self.height = height
        animatableData = times
    }
    
    public func effectValue(size: CGSize) -> ProjectionTransform {

        let transform = CGAffineTransform(translationX: 0, y: -abs(sin(animatableData * .pi)) * height)
        return ProjectionTransform(transform)
    }
}

public struct DropAnimation: GeometryEffect {
    public var height: Double
    
    public var animatableData: Double
    
    private var bezier = CubicBezier(start: CGPoint(x: 0, y: 0), c1: CGPoint(x: 0, y: 0.5), c2: CGPoint(x: 1, y: 1.8), end: CGPoint(x: 1, y: 1))
    
    public init(progress: Double, height: Double) {
        self.height = height
        animatableData = progress
    }

    public func effectValue(size: CGSize) -> ProjectionTransform {
        let bezierValue = bezier.calculate(for: animatableData)
        let transform = CGAffineTransform(translationX: 0, y: bezierValue * height)
        let scale = min(bezierValue, 1)
        let scaleAnchor = CGPoint(x: size.width / 2, y: size.height / 2)
        let scaleTransform = CGAffineTransform(translationX: scaleAnchor.x, y: scaleAnchor.y)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -scaleAnchor.x, y: -scaleAnchor.y)
        return ProjectionTransform(transform).concatenating(ProjectionTransform(scaleTransform))
    }
}

public struct CubicBezier {
    public var c1 = CGPoint(x: 0, y: -0.8)
    public var c2 = CGPoint(x: 1, y: 0.5)
    private var startPoint = CGPoint(x: 0, y: 0)
    private var endPoint = CGPoint(x: 1, y: 1)
        
    public init(start: CGPoint, c1: CGPoint, c2: CGPoint, end: CGPoint) {
        startPoint = start
        endPoint = end
        self.c1 = c1
        self.c2 = c2
    }
    
    public func calculate(for value: CGFloat) -> CGFloat {
        pow(1 - value, 3) * startPoint.y + 3 * pow(1 - value, 2) * value * c1.y + 3 * (1 - value) * value * value * c2.y + pow(value, 3) * endPoint.y
    }
}

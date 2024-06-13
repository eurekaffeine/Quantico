//
//  SAToggle.swift
//
//
//  Created by tianpli on 2024/1/22.
//

import SwiftUI

public class SwitherConfig: ObservableObject {
    public init(title: String = "InPrivate") {
        self.title = title
    }
    
    var circleScale: CGFloat = 0.75
    /// related to the total width of this switcher
    var stretchScale: CGFloat = 0.5
    
    // MARK: title
    var title: String
    
    // MARK: color
    var offBackgroundColor: SAColor = .surfaceQuaternary
    var offTitleColor: SAColor = .textPrimary
    var offToggleColor: SAColor = .iconOnBrand
    var offToggleDarkColor: SAColor = .iconTertiary
    var onBackgroundColor: SAColor = .surfaceBrandPrimary
    var onTitleColor: SAColor = .textOnBrand
    var onToggleColor: SAColor = .iconPrimary
    
    var onChange: (() -> Void)?
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// TODO: limit the width is large than height
public struct SAToggle: View {
    public init(config: SwitherConfig, isOn: Binding<Bool>) {
        self.config = config
        self._isOn = isOn
    }
    
    var config: SwitherConfig
    
    @Binding
    var isOn: Bool
    
    @State
    private var isAnimating: Bool = false
    
    @Environment(\.saTheme)
    private var theme: SATheme
    
    public var body: some View {
        ZStack(alignment: .trailing) {
            HStack(alignment: .center, spacing: .spacing40) {
                Text(config.title)
                    .font(for: .caption1)
                    .foregroundColor(for: isOn ? config.onTitleColor : config.offTitleColor)
                /// the layout direction will change between leftToRight and rightToLeft. the leading always is the side to the super view, and the trailing always is the side connecting the circle
                    .padding(.leading, .spacing60)
                RectangleCircle(scale: 1)
                    .fill(Color.clear)
                    .frame(size: .icon240)
                
            }
            RoundedRectangle(cornerRadius: .infinity)
                .fill((isOn ? config.onToggleColor : (theme == .light ? config.offToggleColor : config.offToggleDarkColor)).color(for: theme))
                .frame(width: isTouched ? .icon240 * (config.stretchScale + 1) : .icon240,
                       height: .icon240)
                .animation(.spring(), value: isAnimating)
                .onAppear {
                    isAnimating = false
                    isAnimating.toggle()
                }

        }
        .padding(.spacing40)
        .environment(\.layoutDirection, isOn ? .leftToRight : .rightToLeft)
        .background((isOn ? config.onBackgroundColor : config.offBackgroundColor).color(for: theme))
        .radius(for: .cornerRadiusInfinity)
        .animation(.default, value: isTouched)
        .animation(.default, value: isOn)
        .gesture(tap)
        .onPreferenceChange(WidthPreferenceKey.self) { (_) in // only for ios 13, it will not update constraints in UIHostingViewController.
            config.onChange?()
        }
    }
    
    // MARK: - Gesture
    @GestureState
    private var isTouched = false
    
    var tap: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isTouched) { (_, gestureState, _) in
                gestureState = true
            }
            .onEnded {_ in
                withAnimation {
                    isOn.toggle()
                }
            }
    }
}

struct RectangleCircle: Shape {
    var scale: CGFloat = 1
    func path(in rect: CGRect) -> Path {
        let heightDistance = (1 - scale) * rect.height
        let frame = CGRect(center: rect.center,
                           size: CGSize(width: rect.width - heightDistance,
                                       height: rect.height - heightDistance))
        let radius = min(frame.height, frame.width) / 2
        let path = Path(roundedRect: frame,
                        cornerRadius: radius)
                
        return path
    }
}

//#Preview {
//    SAToggle(config: SwitherConfig(), isOn: .constant(false))
//}

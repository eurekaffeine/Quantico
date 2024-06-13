import SwiftUI

enum AnimationStage: Equatable {
    case present
    case animating
    case dismiss
    case finished
}

public protocol GoldAnimationDelegate: AnyObject {
    func tap() -> Void
}

public class GoldAnimationViewModel: ObservableObject {
    public init(isPop: Bool = false, configuration: GoldAnimationConfiguration = GoldAnimationConfiguration()) {
        self.isPop = isPop
        self.configuration = configuration
    }
    
    @Published
    public var isPop: Bool = false
    @Published
    public var configuration = GoldAnimationConfiguration()
    
    public weak var delegate: GoldAnimationDelegate?
}

public struct GoldAnimationConfiguration {
    public init(text: String = "", rotationTimes: Int = 7, jumpTimes: Int = 6, goldName: String = "Gold", goldSize: CGFloat = 44) {
        self.text = text
        self.rotationTimes = rotationTimes
        self.jumpTimes = jumpTimes
        self.goldName = goldName
        self.goldSize = goldSize
    }
    
    public var text: String = ""
    public var rotationTimes = 7
    public var jumpTimes = 6
    public var goldName = "Gold"
    public var goldSize: CGFloat = 44
}

public struct GoldView: View {
    public init(isPresent: Binding<Bool>, configuration: GoldAnimationConfiguration, slowAnimation: Double = 1.0) {
        self._isPresent = isPresent
        self.configuration = configuration
        self.slowAnimation = slowAnimation
    }
    
    @Binding
    var isPresent: Bool
    @State
    private var animationStage = AnimationStage.dismiss
    
    public var configuration: GoldAnimationConfiguration
    
    public var slowAnimation = 1.0
    
    private let opacityDuration = Animation.linear(duration: 0.08)
    private var totalRotationDegree: Double {
        Double(configuration.rotationTimes) * 180
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            labelForEarn
                .opacity(labelOpacity)
                .offset(y: CGFloat(labelPosition))
                .modifier(JumpAnimation(repeat: labelJumpTimes, height: 7))
            gold
                .modifier(RotationAnimation(degrees: rotateDegree))
                .opacity(goldOpacity)
        }
        .modifier(DropAnimation(progress: scale, height: positionY))
        .onAppear {
            withAnimation(opacityDuration) {
                goldOpacity = 1
            }
            animationStage = .present
        }
        .onAnimating(for: scale) { value in
            if animationStage == .present && value > 0.84 {
                animationStage = .animating
            } else if animationStage == .dismiss && value == 0 {
                animationStage = .finished
            }
        }
        .onAnimating(for: rotateDegree) { value in
            if animationStage == .animating && value == totalRotationDegree {
                animationStage = .dismiss
            }
        }
        .onChange(of: animationStage) { newValue in
            switch newValue {
            case .present:
                withAnimation(.linear(duration: 0.5 * slowAnimation)) {
                    scale = 1
                    positionY = -80
                }
            case .animating:
                withAnimation(.linear(duration: 0.3 * slowAnimation)) {
                    labelOpacity = 1
                }
                withAnimation(.linear(duration: 4.0 / 3.0 * Double(configuration.rotationTimes) * slowAnimation)) {
                    rotateDegree = totalRotationDegree
                }
                withAnimation(.linear(duration: (6.0 / 4.0 * Double(configuration.jumpTimes) + 1.0 / 3.0) * slowAnimation)) {
                    labelJumpTimes = Double(configuration.jumpTimes)
                }
            case .dismiss:
                let dropAnimationDuration = 0.5 * slowAnimation
                let dropAnimation = Animation.linear(duration: dropAnimationDuration)
                withAnimation(.easeIn(duration: 0.15 * slowAnimation)) {
                    labelOpacity = 0
                }
                withAnimation(dropAnimation) {
                    positionY = -80
                    labelPosition = -20
                    scale = 0
                }
            case .finished:
                isPresent = false
            }
        }
    }
    
    @State private var positionY = -65.0
    
    @State private var goldOpacity = 0.0
    @State private var scale = 0.0
    @State private var rotateDegree = 0.0
    private var gold: some View {
        Image(configuration.goldName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(1)
            .frame(width: configuration.goldSize, height: configuration.goldSize)
    }
    
    @State private var labelOpacity = 0.0
    @State private var labelPosition = 0.0
    @State private var labelJumpTimes = 0.0
    
    private var labelForEarn: some View {
        ZStack {
            Text(configuration.text)
                .foregroundColor(.white)
                .font(.system(size: 12, weight: .bold))
                .multilineTextAlignment(.center)
                .fixedSize()
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 3, trailing: 8))
                .background(HintLabelShape().fill(Color("#3D6CDC"), style: FillStyle(eoFill: true, antialiased: true)))
                .offset(y: -HintLabelShape.arrowWidth)
        }
    }
}

struct HintLabelShape: Shape {
    private static let cornerRadius: CGFloat = 8
    static let arrowWidth: CGFloat = 6
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - Self.arrowWidth,
                              y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY + Self.arrowWidth))
        path.addLine(to: CGPoint(x: rect.midX + Self.arrowWidth,
                                 y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.maxX - Self.cornerRadius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.maxX - Self.cornerRadius,
                                    y: rect.maxY - Self.cornerRadius),
                    radius: Self.cornerRadius,
                    startAngle: Angle(radians: .pi * 0.5),
                    endAngle: Angle(radians: 0),
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY - Self.cornerRadius))
        path.addArc(center: CGPoint(x: rect.maxX - Self.cornerRadius,
                                    y: rect.minY + Self.cornerRadius),
                    radius: Self.cornerRadius,
                    startAngle: Angle(radians: 0),
                    endAngle: Angle(radians: .pi * 1.5),
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.minX + Self.cornerRadius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.minX + Self.cornerRadius,
                                    y: rect.minY + Self.cornerRadius),
                    radius: Self.cornerRadius,
                    startAngle: Angle(radians: .pi * 1.5),
                    endAngle: Angle(radians: .pi * 1),
                    clockwise: true)
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - Self.cornerRadius))
        path.addArc(center: CGPoint(x: rect.minX + Self.cornerRadius,
                                    y: rect.maxY - Self.cornerRadius),
                    radius: Self.cornerRadius,
                    startAngle: Angle(radians: .pi),
                    endAngle: Angle(radians: .pi * 0.5),
                    clockwise: true)
        
        return path
    }
}

struct TestGoldView: View {
    
    @State private var warning = true
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                
                Button {
                    withAnimation {
                        warning = true
                    }
                } label: {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40, alignment: .center)
                }
                
                if warning {
                    GoldView(isPresent: $warning, configuration: GoldAnimationConfiguration())
                        .transition(.opacity)
                }
            }
            Text("\(warning ? "true" : "false")")
        }
    }
}

struct GoldView_Previews: PreviewProvider {
    static var previews: some View {
        
        TestGoldView()
    }
}

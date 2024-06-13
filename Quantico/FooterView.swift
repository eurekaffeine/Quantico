//
//  FooterView.swift
//  Quantico
//
//  Created by Yaochen Liu on 2024/6/12.
//

//
//  FooterView.swift
//
//
//  Created by tianpli on 2023/7/21.
//
#if os(iOS)
import SwiftUI
import UIKit

// MARK: - Notification View Modifier
public protocol Noticable {
    var isRedDot: Bool { get }
}

struct NoticeViewModifier: ViewModifier {
    var isNotify: Bool
    var color: Color = .red
    var paddingColor: Color = .clear
    
    func body(content: Content) -> some View {
        if isNotify {
            content
                .overlayView(alignment: .topTrailing) {
                    ZStack {
                        Circle()
                            .foregroundColor(paddingColor)
                            .frame(width: Constants.size + Constants.padding * 2,
                                   height: Constants.size + Constants.padding * 2)
                        Circle()
                            .foregroundColor(color)
                            .frame(width: Constants.size, height: Constants.size)
                    }
                    .offset(x: Constants.padding, y: -Constants.padding)
                }
        } else {
            content
        }
    }
    
    private struct Constants {
        static let size: CGFloat = 8
        static let padding: CGFloat = 2
    }
}

// MARK: - Global Footer View
public protocol GlobalFooterViewDelegate: AnyObject {
    func tap(item: FooterTabItem)
}

@MainActor
public class GlobalFooterViewModel: ObservableObject {
    public init(style: FooterViewStyle,
                tabs: FooterTabs,
                isHidden: Bool = false,
                hideSydney: Bool = false) {
        self.style = style
        self.tabs = tabs
        self.isHidden = isHidden
        self.hideSydney = hideSydney
    }
    
    @Published
    public var style: FooterViewStyle
    @Published
    public var tabs: FooterTabs
    @Published
    public var isHidden = false
    
    @Published
    public var hideSydney: Bool
    
    public weak var delegate: GlobalFooterViewDelegate?
}


public struct FooterView: View {
    public init(goldViewModel: GoldAnimationViewModel, footerViewModel: GlobalFooterViewModel) {
        self.goldViewModel = goldViewModel
        self.footerViewModel = footerViewModel
    }
    
    @ObservedObject
    public var goldViewModel: GoldAnimationViewModel
    @ObservedObject
    public var footerViewModel: GlobalFooterViewModel
    
    @State
    private var layoutDirection: LayoutDirection = .leftToRight
    // Gold view
    @State
    private var shakeTimes = 0
    
    public var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                Spacer()
                bottomView
            }
            .offset(y: max(0, proxy.safeAreaInsets.bottom - Constants.footerVerticalOffset))
            .isHidden(footerViewModel.isHidden)
            .transition(.move(edge: .bottom))
        }.environment(\.layoutDirection, layoutDirection)
    }
    
    @ViewBuilder
    private var bottomView: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                footerBackgroundView
                sideTabListView
                    .padding(.horizontal, Constants.minTabsHorizontalPadding)
                
            }
            .frame(height: Constants.tabHeight)
            
            // in case the wheel style, put the center one on the other tabs.
            HStack(spacing: 0) {
                Color.clear
                Color.clear
                if !footerViewModel.hideSydney {
                    centerView(item: footerViewModel.tabs.center)
                        .frame(height: Constants.centerTabHeight)
                }
                Color.clear
                Color.clear
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, Constants.minTabsHorizontalPadding)
        }
    }
    
    @ViewBuilder
    private var footerBackgroundView: some View {
        ZStack {
            let shape = footerViewModel.hideSydney ?
                        CenterPopRectangle(height: CGFloat(0), // when sydney is hidden, we want a rectangle, thus the height here need to be zero
                          topContolLegngth : Constants.centerPopTopControlLength,
                          downContolLegngth: Constants.centerPopDownControlLength,
                                           width: Constants.centerPopWidth) :
                        CenterPopRectangle(height: Constants.centerPopHeight,
                          topContolLegngth : Constants.centerPopTopControlLength,
                          downContolLegngth: Constants.centerPopDownControlLength,
                                           width: Constants.centerPopWidth)
            footerViewModel.style.innerShadowColor
                .mask(shape)
            footerViewModel.style.backgroundColor
                .mask(shape)
                .padding(.top, Constants.innerShadowWidth)
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private var sideTabListView: some View {
        HStack(alignment: .bottom, spacing: 0) {
            tabView(item: footerViewModel.tabs.leftOutside)
            tabView(item: footerViewModel.tabs.leftInside)
            if !footerViewModel.hideSydney {
                Color.clear
            }
            tabView(item: footerViewModel.tabs.rightInside)
            tabView(item: footerViewModel.tabs.rightOutside)
                .overlayView {
                    VStack {
                        if goldViewModel.isPop {
                            GoldView(isPresent: $goldViewModel.isPop,
                                     configuration: goldViewModel.configuration,
                                     slowAnimation: 1)
                            .onTapGesture {
                                goldViewModel.delegate?.tap()
                            }
                        }
                    }
                }
                .modifier(CenterShakeAnimation(repeat: shakeTimes))
                .onChange(of: goldViewModel.isPop) { newValue in
                    if !newValue {
                        withAnimation {
                            shakeTimes = 2
                        }
                    } else {
                        shakeTimes = 0
                    }
                }
        }
        .frame(height: Constants.tabHeight)
        .frame(maxWidth: footerViewModel.style.maxWidth)
    }
    
    @ViewBuilder
    private func centerView(item: FooterTabItem) -> some View {
        titleContainerView(item: item, spacing: 4) {
            footerViewModel.delegate?.tap(item: item)
        } label: {
            let size = Constants.centerIconSize // + Constants.centerTabSpacing * 2 // for animation pading
            Spacer(minLength: 0)
            let image = Image(platformImage: item.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
            image
        }
    }
    
    @ViewBuilder
    private func tabView(item: FooterTabItem) -> some View {
        titleContainerView(item: item, spacing: 0) {
            footerViewModel.delegate?.tap(item: item)
        } label: {
            let iconSize = Constants.tabIconSize
            VStack(spacing: 0) {
                Image(platformImage: item.isSelected ? (item.iconFilled ?? item.icon) : item.icon)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor( item.isSelected ? footerViewModel.style.tab.iconColorSelected : footerViewModel.style.tab.iconColor)
                    .frame(width: iconSize, height: iconSize)
                    .modifier(NoticeViewModifier(isNotify: item.isRedDot,
                                                 color: footerViewModel.style.tab.notificationColor,
                                                 paddingColor: footerViewModel.style.backgroundColor))
            }
        }
        .disabled(!item.isEnabled)
    }
    
    @ViewBuilder
    private func titleContainerView<Label: View>(item: FooterTabItem,
                                                 spacing: CGFloat,
                                                 action: @escaping () -> Void,
                                                 @ViewBuilder
                                                 label: () -> Label) -> some View {
        Button(action: action) {
            VStack(spacing: spacing) {
                label()
                // title
                Text(item.title)
                    .font(footerViewModel.style.tab.titleFont)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, Constants.textVerticalPadding)
                    .foregroundColor(item.isSelected ? footerViewModel.style.tab.titleColorSelected : footerViewModel.style.tab.titleColor)
                    .padding(.bottom, Constants.titleBottomPadding)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement()
        .accessibility(addTraits: .isButton)
        .accessibilityIdentifier(item.accessibilityId)
        .accessibilityLabel(item.title)
        .accessibility(addTraits: item.isSelected ? .isSelected : [])
    }
    
    private struct Constants {
        // bing design alignment
        static let textVerticalPadding: CGFloat = 1
        // single tab
        static let titleBottomPadding: CGFloat = 2
        static let tabIconTopPadding: CGFloat = 5
        
        static let indicatorWidth: CGFloat = 24 // It same as icon size for 23.07 version
        static let indicatorHeight: CGFloat = 3
        
        static let tabIconSize: CGFloat = 24
        static let centerIconSize: CGFloat = 32
        static let chatBreathSize: CGFloat = 52
        static let copilotAnimationSize: CGFloat = 45
        static let tabHeight: CGFloat = 50
        static let centerTabHeight: CGFloat = 54
        
        // background
        static let centerPopHeight: CGFloat = 10
        static let centerPopWidth: CGFloat = 73
        static let centerPopTopControlLength: CGFloat = 16
        static let centerPopDownControlLength: CGFloat = 12.5
        static let innerShadowWidth: CGFloat = 1
        
        // other
        static let centerTabSpacing: CGFloat = 4
        static let minTabsHorizontalPadding: CGFloat = 16
        static let footerVerticalOffset: CGFloat = 26
    }
}

// MARK: - Global Footer Model
public struct FooterTabStyle {
    public init(indicatorColor: Color, iconColor: Color, titleColor: Color, titleFont: Font, notificationColor: Color, iconColorSelected: Color, titleColorSelected: Color) {
        self.indicatorColor = indicatorColor
        self.iconColor = iconColor
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.notificationColor = notificationColor
        self.iconColorSelected = iconColorSelected
        self.titleColorSelected = titleColorSelected
    }
    
    public var indicatorColor: Color
    public var iconColor: Color
    public var iconColorSelected: Color
    public var titleColor: Color
    public var titleColorSelected: Color
    public var titleFont: Font
    
    public var notificationColor: Color
}

public struct FooterViewStyle {
    public init(backgroundColor: Color, innerShadowColor: Color, tab: FooterTabStyle, maxWidth: CGFloat = 400) {
        self.backgroundColor = backgroundColor
        self.innerShadowColor = innerShadowColor
        self.tab = tab
        self.maxWidth = maxWidth
    }
    
    public var backgroundColor: Color
    public var innerShadowColor: Color
    
    public var tab: FooterTabStyle
    
    public var maxWidth: CGFloat = 400// For iPad old design
}

public struct FooterTabs {
    public init(leftOutside: FooterTabItem, leftInside: FooterTabItem, center: FooterTabItem, rightInside: FooterTabItem, rightOutside: FooterTabItem) {
        self.leftOutside = leftOutside
        self.leftInside = leftInside
        self.center = center
        self.rightInside = rightInside
        self.rightOutside = rightOutside
    }
    
    public var leftOutside: FooterTabItem
    public var leftInside: FooterTabItem
    public var center: FooterTabItem
    public var rightInside: FooterTabItem
    public var rightOutside: FooterTabItem
}

public struct FooterTabItem {
    public init(id: String, accessibilityId: String, title: String, icon: PlatformImage, isSelected: Bool = false, isEnabled: Bool = true, isRedDot: Bool = false, iconFilled: PlatformImage? = nil) {
        self.id = id
        self.accessibilityId = accessibilityId
        self.title = title
        self.icon = icon
        self.iconFilled = (iconFilled == UIImage()) ? nil : iconFilled
        self.isSelected = isSelected
        self.isEnabled = isEnabled
        self.isRedDot = isRedDot
    }
    
    public var id: String
    public var accessibilityId: String
    
    public var title: String
    public var icon: PlatformImage
    public var iconFilled: PlatformImage?
    
    public var isSelected: Bool = false
    public var isEnabled: Bool = true// not use for current version. It was used for `back` item.
    public var isRedDot: Bool = false
}

public struct ChatAnimationModel {
    public var isPlaying: Bool = false
    public var isEnable: Bool = false
    public init(isPlaying: Bool = false, isEnable: Bool = false) {
        self.isPlaying = isPlaying
        self.isEnable = isEnable
    }
}

// MARK: - Preview
struct FooterView_Previews: PreviewProvider {
    static var previews: some View {
        FooterView(goldViewModel: GoldAnimationViewModel(),
                   footerViewModel: GlobalFooterViewModel(style: FooterViewStyle(backgroundColor: SAColor.surfacePrimary.color(for: .light),
                                                                                 innerShadowColor: SAColor.dividerPrimary.color(for: .light),
                                                                                 tab: FooterTabStyle(indicatorColor: SAColor.iconBrandPrimary.color(for: .light),
                                                                                                     iconColor: SAColor.iconSecondary.color(for: .light),
                                                                                                     titleColor: SAColor.iconSecondary.color(for: .light),
                                                                                                     titleFont: Font.custom("SF Pro Text", size: 12),
                                                                                                     notificationColor: SAColor.iconDanger.color(for: .light),
                                                                                                     iconColorSelected: SAColor.iconBrandPrimary.color(for: .light),
                                                                                                     titleColorSelected: SAColor.textBrandPrimary.color(for: .light))
),
                                                          tabs: FooterTabs(leftOutside: FooterTabItem(id: "home",
                                                                                                      accessibilityId: "home",
                                                                                                      title: "HomeGg",
                                                                                                      icon: UIImage(named: "Home")!),
                                                                           leftInside: FooterTabItem(id: "home",
                                                                                                     accessibilityId: "home",
                                                                                                     title: "News",
                                                                                                     icon: UIImage(named: "News")!),
                                                                           center: FooterTabItem(id: "home",
                                                                                                 accessibilityId: "home",
                                                                                                 title: "Chat",
                                                                                                 icon: UIImage(named: "Copilot")!),
                                                                           rightInside: FooterTabItem(id: "home",
                                                                                                      accessibilityId: "home",
                                                                                                      title: "Tabs",
                                                                                                      icon: UIImage(named: "tabs0")!),
                                                                           rightOutside: FooterTabItem(id: "home",
                                                                                                       accessibilityId: "home",
                                                                                                       title: "Apps",
                                                                                                       icon: PlatformImage(named: "Apps")!))))
    }
}
#endif

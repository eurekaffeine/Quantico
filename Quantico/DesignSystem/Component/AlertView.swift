//
//  AlertView.swift
//
//
//  Created by 李天培 on 2023/12/5.
//

import SwiftUI

// TODO: Rename to SAButtonConfiguration
public struct AlertAction {
    public init(label: String, icon: PlatformImage? = nil, style: AlertActionStyle = .default, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    public var label: String
    public var icon: PlatformImage?
    public var style: AlertActionStyle = .default
    public var action: () -> Void
}

public struct AlertOption {
    public init(message: String, icon: PlatformImage, status: Bool = false, select: @escaping (Bool) -> Void) {
        self.message = message
        self.icon = icon
        self.status = status
        self.select = select
    }
    
    public var message: String
    public var icon: PlatformImage
    public var status: Bool = false
    public var select: (Bool) -> Void
}

public struct AlertInput {
    public init(placeholder: String, inputAction: @escaping (String) -> Void) {
        self.placeholder = placeholder
        self.inputAction = inputAction
    }
    var placeholder: String
    public var inputAction: (String) -> Void
}

public struct DialogClose {
    public init(icon: PlatformImage, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    public var icon: PlatformImage
    public var action: () -> Void
}

@MainActor
public class AlertViewModel: ObservableObject {
    public static let shared = AlertViewModel()
    
    public func show(title: String?,
                     message: String?,
                     illustration: Imagable? = nil,
                     options: AlertOption...,
                     input: AlertInput? = nil,
                     actionsAxis: Axis = .horizontal,
                     actions: AlertAction..., 
                     close: DialogClose? = nil) {
        self.title = title
        self.message = message
        self.illustration = illustration
        self.options = options
        self.input = input
        self.actions = actions
        self.actionsAxis = actionsAxis
        self.close = close
        withAnimation(.easeInOut) {
            self.isPresent = true
        }
    }
    
    public func dismiss() {
        withAnimation(.easeInOut) {
            isPresent = false
        }
    }
        
    @Published
    var title: String?
    @Published
    var message: String?
    @Published
    var illustration: Imagable?
    @Published
    var options: [AlertOption] = []
    
    @Published
    var input: AlertInput?
    @Published
    var actionsAxis: Axis = .vertical
    @Published
    var actions: [AlertAction] = []
    
    @Published
    var close: DialogClose? = nil
    
    @Published
    var isPresent: Bool = false
}

public struct AlertView: View {
    public init(viewModel: AlertViewModel) {
        self.viewModel = viewModel
    }
    
    @ObservedObject
    var viewModel: AlertViewModel
    
    @State
    private var inputText: String = ""
    @Environment(\.saTheme)
    private var theme: SATheme

    public var body: some View {
        ZStack {
            if viewModel.isPresent {
                SAOverlayView()
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: .spacing240) {
                        VStack {
                            if let illustration = viewModel.illustration {
                                ImagableView(imagable: illustration) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Spacer(minLength: 0)
                                }
                                .frame(maxWidth: .infinity, maxHeight: 180)
                                .clipped()
                            }
                        }
                        
                        VStack(spacing: .spacing120) {
                            VStack(spacing: .spacing80) {
                                headerLine
                                messageView
                            }
                            if !viewModel.options.isEmpty {
                                optionsView
                            }
                            if let _ = viewModel.input {
                                textInputView
                                    .onDisappear {
                                        inputText = ""
                                    }
                            }
                        }
                        .padding(.horizontal, .spacing240)
                        actionsView
                            .padding(.horizontal, .spacing240)
                    }
                    .padding(.bottom, .spacing240)
                    if let close = viewModel.close {
                        Button {
                            close.action()
                        } label: {
                            Image(platformImage: close.icon)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(for: .iconPrimary)
                                .frame(size: .icon240)
                                .padding(.spacing160)
                        }
                    }
                }
                .zIndex(1)
                .backgroundColor(for: .surfaceSecondary)
                .radius(for: .cornerRadius240)
//                .shadow(for: .shadow04) // TODO: design
                .padding(.spacing320)
            }
        }
    }
    @ViewBuilder
    private var optionsView: some View {
        VStack(spacing: .spacing160) {
            let isSingleRowOption = viewModel.options.count == 1
            ForEach(viewModel.options.indices, id: \.self) { index in
                let option = viewModel.options[index]
                let binding = Binding {
                    viewModel.options[index].status
                } set: { status in
                    viewModel.options[index].status = status
                    viewModel.options[index].select(status)
                }
                AlertCheckmarkView(message: option.message, checkIcon: option.icon, isSingle: isSingleRowOption, isChecked: binding)
            }
        }
    }
    
    @ViewBuilder
    private var textInputView: some View {
        ZStack(alignment: .leading) {
            if inputText.isEmpty {
                Text(viewModel.input!.placeholder)
                    .font(for: .body2)
                    .foregroundColor(for: .textSecondary)
                    .padding(.horizontal, .spacing80)
            }
            TextField("", text: $inputText)
                .onAppear {
                #if canImport(UIKit)
                    UITextField.appearance().clearButtonMode = .whileEditing
                #endif
                }
                .onChange(of: inputText) { newValue in
                    viewModel.input?.inputAction(newValue)
                }
                #if os(iOS)
                .textInputAutocapitalization(.none)
                #endif
                .foregroundColor(for: .textPrimary)
                .frame(height: .spacing480)
                .padding(.horizontal, .spacing80)
                .disableAutocorrection(true)
        }
        .radius(for: .cornerRadius80, stroke: (color: SAColor.dividerSecondary.color(for: theme), width: .strokeWidth10))
    }
    
    @ViewBuilder
    private var actionsView: some View {
        let actions = ForEach(viewModel.actions.indices, id: \.self) {
            let action = viewModel.actions[$0]
            switch action.style {
            case .default:
                SAButton(style: .secondary,
                         size: .large,
                         state: .normal,
                         label: action.label,
                         icon: action.icon,
                         action: action.action)
            case .confirm:
                SAButton(style: .primary, 
                         size: .large,
                         state: .normal,
                         label: action.label,
                         icon: action.icon,
                         action: action.action)
            case .danger:
                SAButton(style: .secondary,
                         size: .large,
                         state: .warning,
                         label: action.label,
                         icon: action.icon,
                         action: action.action)
            }
        }
        if viewModel.actionsAxis == .horizontal {
            HStack(spacing: .spacing160) {
                actions
            }
        } else {
            VStack(spacing: .spacing160) {
               actions
            }
        }
    }
    
    @ViewBuilder
    private var messageView: some View {
        if let message = viewModel.message {
            Text(message)
                .font(for: .body1)
                .multilineTextAlignment(.center)
                .foregroundColor(for: .textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    @ViewBuilder
    private var headerLine: some View {
        if let title = viewModel.title {
            Text(title)
                .font(for: .title2)
                .multilineTextAlignment(.center)
                .foregroundColor(for: .textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

public enum AlertActionStyle {
    case `default`
    case confirm
    case danger
    
    var textColor: SAColor {
        switch self {
        case .default:
            return .textPrimary
        case .confirm:
            return .textOnBrand
        case .danger:
            return .textDanger
        }
    }
}

struct AlertCheckmarkView: View {
    var message: String
    var checkIcon: PlatformImage
    var isSingle: Bool = false
    @Binding
    var isChecked: Bool
    @Environment(\.saTheme)
    private var theme: SATheme
    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            let view = HStack(spacing: .spacing120) {
                    checkIconView
                        .padding(.spacing20)
                    
                    Text(message)
                        .font(for: .body2)
                        .foregroundColor(for: .textSecondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
            if isSingle {
                view
            } else {
                view.padding(.spacing120)
                    .radius(for: .cornerRadius80, stroke: (strokeColor, .strokeWidth10))
            }
        }
    }
    
    @ViewBuilder
    private var checkIconView: some View {
        ZStack {
            if isChecked {
                ZStack {
                    Circle().fill(SAColor.surfaceBrandPrimary.color(for: theme))
                    Image(platformImage: checkIcon)
                        .renderingMode(.template)
                        .resizable()
                        .foregroundColor(for: .iconOnBrand)
                        .frame(size: 14)
                        .padding(3)
                }
            } else {
                Circle()
                    .stroke(lineWidth: SALayout.StrokeWidth.strokeWidth15.value)
                    .foregroundColor(for: .dividerTeriary)
            }
        }
        .frame(size: .icon200)
    }
    
    private var strokeColor: Color {
        if isChecked {
            return SAColor.borderBrandPrimary.color(for: theme)
        } else {
            return SAColor.dividerPrimary.color(for: theme)
        }
    }
}

struct AlertOptionView: View {
    var optionMessage: String
    @Binding
    var isSelected: Bool
    @Environment(\.saTheme)
    private var theme: SATheme
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            HStack(spacing: .spacing120) {
                Text(optionMessage)
                    .font(for: .caption1)
                    .foregroundColor(for: .textPrimary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                selectIcon
            }
            .padding(.spacing120)
            .frame(maxWidth: .infinity)
            .radius(for: .cornerRadius80, stroke: (strokeColor, .strokeWidth10))
        }
    }
    
    @ViewBuilder
    private var selectIcon: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: SALayout.StrokeWidth.strokeWidth15.value)
                .foregroundColor(for: isSelected ? .iconBrandPrimary : .dividerTeriary)
            Circle()
                .fill((isSelected ? SAColor.iconBrandPrimary : .clear).color(for: theme))
                .frame(size: .icon100)
        }
        .frame(size: .icon200)
    }
    
    private var strokeColor: Color {
        if isSelected {
            return SAColor.borderBrandPrimary.color(for: theme)
        } else {
            return SAColor.dividerPrimary.color(for: theme)
        }
    }
}

//#Preview {
//    Group {
//        ZStack {
//            SAButton(label: "Trigger") {
//                AlertViewModel.shared.show(title: "Delete password?",
//                                           message: "Deleting this password will not delete your account on mobile.twitter.com", 
//                                           illustration:  .url("https://media.istockphoto.com/id/1453715348/ja/ストックフォト/日本の美しい峡谷である西川渓谷.jpg?s=2048x2048&w=is&k=20&c=0e3s4ppxHFD2utDT33Jqw3Kx-pQn9BMs3JqXpQ9Jky8="),
////                                           options: AlertOption(message: "Clear favorites, history, passwords, and other browsing data from this device",
////                                                                status: true, select: { _ in
////                    
////                }),
//                                           actionsAxis: .vertical,
//                                           actions: AlertAction(label: "Cancel", icon: PlatformImage(systemName: "hand.thumbsup")!, action: {
//                    AlertViewModel.shared.dismiss()
//                }), 
//                                           AlertAction(label: "Delete", icon: PlatformImage(systemName: "hand.thumbsdown")!, style: .danger, action: {
//                    AlertViewModel.shared.dismiss()
//                }), close: DialogClose(icon: PlatformImage(systemName: "xmark")!, action: {
//                    AlertViewModel.shared.dismiss()
//                })
//                )
//            }
//            AlertView(viewModel: .shared)
//        }
//        .environment(\.saTheme, .light)
//    }
//}

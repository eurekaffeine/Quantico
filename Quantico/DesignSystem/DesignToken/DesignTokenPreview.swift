//
//  SwiftUIView.swift
//  
//
//  Created by 李天培 on 2023/10/19.
//

import SwiftUI

@available(iOS 15.0, *)
struct ColorTokenView: View {
    @Environment(\.saTheme)
    private var theme: SATheme
    
    var body: some View {
        ScrollView {
            ForEach(SAColor.allCases, id: \.name) {
                saColorView(color: $0)
            }
            
            ForEach(GlobalColor.allCases, id: \.rawValue) {
                globalColorView(color: $0)
            }
        }
    }
    
    @ViewBuilder
    private func saColorView(color: SAColor) -> some View {
        VStack(alignment: .leading) {
            Text(color.name.components(separatedBy: ".").last ?? "").padding(.horizontal)
            HStack(spacing: 16) {
                globalColorView(color: color.globalColor(for: .light))
                globalColorView(color: color.globalColor(for: .dark))
            }
            .padding()
        }
    }
    
    @ViewBuilder func globalColorView(color: GlobalColor) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(String(reflecting: color).components(separatedBy: ".").last ?? "")
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .colorInvert()

            Text(color.rawValue)
                .colorInvert()
        }
        .padding(4)
        .foregroundColor(color.color)
        .background(color.color)
        .clipShape(RoundedRectangle(cornerRadius: 8), style: FillStyle(eoFill: true))
        .radius(for: .cornerRadius20, stroke: (SAColor.dividerPrimary.color(for: theme), .strokeWidth15))
    }
}

extension SAColor {
    
    var name: String {
        String(reflecting: self)
    }
    
    var category: String {
        switch self {
        case .surfaceCanvas,
                .surfacePrimary,
                .surfaceSecondary,
                .surfaceTertiary,
                .surfaceQuaternary,
                .surfaceBrandPrimary,
                .surfaceBrandSecondary,
                .surfaceBrandTertiary,
                .surfaceDanger,
                .surfaceSuccess,
                .surfaceSevere,
                .surfaceInput:
            return "Surface"
        case .textPrimary,
                .textSecondary,
                .textTertiary,
                .textDisabled,
                .textOnBrand,
                .textBrandPrimary,
                .textBrandSecondary,
                .textBrandDisabled,
                .textDanger,
                .textSuccess,
                .textSevere:
            return "Text"
        case .dividerPrimary,
                .dividerSecondary,
                .dividerTeriary,
                .borderPrimary,
                .borderDisabled,
                .borderBrandPrimary,
                .borderBrandSecondary,
                .borderDanger,
                .borderSuccess,
                .borderSevere:
            return "Divider"
        case .iconPrimary,
                .iconSecondary,
                .iconTertiary,
                .iconDisabled,
                .iconOnBrand,
                .iconBrandPrimary,
                .iconBrandSecondary,
                .iconBrandDisabled,
                .iconDanger,
                .iconSuccess,
                .iconSevere:
            return "Icon"
        case .secondaryDanger,
                .secondarySuccess,
                .secondarySevere,
                .secondaryWarning:
            return "Secondary"
        case .clear:
            return "Special"
        }
    }
}

//#Preview {
//    ColorTokenView()
//}

// MARK: - SAFont Preview
extension SAFont {
    public var name: String {
        return "\(self)"
    }
}

//#Preview {
//    SAFontPreviewView()
//}

struct SAFontPreviewView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                ForEach(SAFont.allCases, id: \.name) {
                    fontView(safont: $0)
                }
            }
        }
    }
    
    @ViewBuilder
    private func fontView(safont: SAFont) -> some View {
        VStack {
            LazyHGrid(rows: [GridItem(.flexible())]) {
                LazyVGrid(columns: [GridItem(.flexible())]) {
                    info(title: "Family", value: safont.family)
                    info(title: "Weight", value: "\(safont.weight)")
                    info(title: "LineSpacing", value: "\(safont.lineSpacing)")
                    info(title: "Size", value: "\(safont.size)")
                }
                Text(safont.name)
                    .font(for: safont)
                    .modifier(FrameLabelViewModifier())
                    .layoutPriority(3)
            }
        }
    }
    
    @ViewBuilder
    private func info(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(for: .body1)
            Text(value)
                .font(for: .caption1)
        }
    }
}

struct FrameLabelViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        let color = Color.blue
        content
            .overlay(content: {
                GeometryReader(content: { geometry in
                    Rectangle().stroke(color, lineWidth: 1.0)
                        .overlay(alignment: .top) {
                            Text("\(geometry.size.width, specifier: "%.2f")")
                                .font(.caption2)
                                .foregroundColor(color)
                                .offset(y: -20)
                        }
                        .overlay(alignment: .leading) {
                            Text("\(geometry.size.height, specifier: "%.2f")")
                                .font(.caption2)
                                .foregroundColor(color)
                                .offset(x: geometry.size.width + 10)
                        }
                })
            })
    }
}
